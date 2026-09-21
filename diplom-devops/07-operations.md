
# Глава 6. Эксплуатация и обслуживание

## 6.1 Работа с прерываемыми ВМ

Для экономии бюджета worker-узлы созданы как **прерываемые** ВМ.
Yandex Cloud останавливает такие ВМ раз в 24 часа, а также при
дефиците ресурсов в зоне. Это даёт существенную скидку (до 70%
от стоимости обычной ВМ), но накладывает требования к архитектуре.

### 6.1.1 Что происходит при прерывании

1. Yandex Cloud отправляет ВМ сигнал на остановку.
2. Через 30 секунд ВМ выключается.
3. Все поды на узле перестают работать.
4. Kubernetes помечает узел как `NotReady`.
5. Через 5–10 минут поды пересоздаются на других узлах.
6. Yandex Cloud автоматически запускает ВМ заново.
7. Узел регистрируется в кластере, поды возвращаются.

### 6.1.2 Требования к приложениям

Чтобы прерывание не приводило к сбоям, нужно:

- **Несколько реплик приложения.** У нас `replicas: 2` для
  `diplom-app` — если одна реплика остановится, вторая продолжит
  обслуживать трафик.
- **Pod Anti-Affinity.** Реплики размещаются на разных узлах:
  ```yaml
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app: diplom-app
            topologyKey: kubernetes.io/hostname
  ```
- **Readiness probes.** Kubernetes не направляет трафик на поды,
  пока они не готовы.
- **Толерантность к сетевым сбоям.** Если приложение зависит от
  базы данных на другом узле, оно должно переподключаться
  автоматически.

### 6.1.3 Проблема с публичным IP

Первое, с чем я столкнулся: после прерывания bastion-хоста у него
**терялся публичный IP**. Динамические IP в Yandex Cloud отвязываются
от ВМ при остановке и возвращаются в общий пул.

Решение — зарезервировать статический IP:

```hcl
resource "yandex_vpc_address" "bastion_ip" {
  name        = "diplom-bastion-ip"
  folder_id   = var.folder_id
  description = "Статический публичный IP для bastion"

  external_ipv4_address {
    zone_id = var.bastion_zone
  }
}

resource "yandex_compute_instance" "bastion" {
  network_interface {
    subnet_id      = var.public_subnet_id
    nat            = true
    nat_ip_address = yandex_vpc_address.bastion_ip.external_ipv4_address[0].address
    security_group_ids = [var.security_group_ids["sg-bastion"]]
  }
}
```

Теперь bastion всегда получает один и тот же IP, независимо от
перезапусков. Это критично для SSH-конфига и DNS-записей.

### 6.1.4 Проблема с OOM

Второе важное наблюдение: после прерывания узла все поды мониторинга
переехали на один узел. Тяжёлые компоненты (Grafana + Prometheus)
не уложились в память — OOM-killer убивал Grafana.

Решение (описано в главе 4):

1. `topologySpreadConstraints` для распределения подов
   по узлам.
2. `podAntiAffinity` для пар Grafana↔Prometheus.
3. Установлены явные limits для всех компонентов.

После этих изменений распределение стабилизировалось: Grafana и
Prometheus всегда на разных узлах, память не превышает 70%.

**Место для скриншота 54:** `kubectl top nodes` с выровненной
нагрузкой.

## 6.2 Обновление приложения

Рассмотрим два сценария: изменение кода и откат.

### 6.2.1 Обычное обновление

1. Изменение в `app/index.html`, коммит в feature-ветку.
2. PR → ревью → мерж в main.
3. Автоматически запускается `build.yml` — образ с тегом `latest`
   попадает в реестр.
4. Создание тега `v0.2.0`:

```bash
git checkout main
git pull
git tag -a v0.2.0 -m "Обновление главной страницы"
git push origin v0.2.0
```

5. Запускается `release.yml`:
   - Собирает образ с тегом `v0.2.0` и `latest`.
   - Пушит в реестр.
   - Отправляет `repository_dispatch` в k8s-репо.
6. Запускается `deploy.yml`:
   - Рендерит `config/app/diplom-app.yaml` с `IMAGE_TAG=v0.2.0`.
   - Применяет манифест.
   - Ждёт завершения `kubectl rollout status`.

Приложение обновляется без простоя: Kubernetes использует
**rolling update** по умолчанию. Старые поды постепенно
заменяются новыми.

### 6.2.2 Откат

Если новая версия сломала приложение, есть два способа.

**Способ 1. Через Git revert.** Отменить коммит, запушить в main,
создать новый тег — workflow задеплоит предыдущую версию.

**Способ 2. Через переопределение образа.** Запустить `Deploy App`
вручную с указанием старой версии:

```
Actions → Deploy App → Run workflow
version: v0.1.0
```

Workflow обновит Deployment на старый образ. Через минуту приложение
вернётся к рабочему состоянию.

**Место для скриншота 55:** запуск `Deploy App` вручную с указанием
версии `v0.1.0`.

## 6.3 Обновление инфраструктуры

Изменения в Terraform-коде применяются так:

1. Правка в `infrastructure/` или `modules/`.
2. PR → в логах workflow виден `terraform plan` с ожидаемыми
   изменениями.
3. Мерж в main → автоматически запускается `terraform apply`.
4. Terraform приводит ресурсы к новому состоянию.

**Пример:** добавление новой роли SA. Правка в `module.iam_k8s`,
PR, мерж — роль добавлена без пересоздания чего-либо.

**Опасные операции.** Некоторые изменения приводят к
**пересозданию ресурса** (`forces replacement`). Например:

- Изменение `platform_id` у ВМ.
- Изменение `zone` у ВМ.
- Изменение `nat_ip_address`.

Перед мержем такого PR нужно проверить план: если ресурс
пересоздаётся, это может привести к простою. Обычно такие
изменения делают ночью или в отдельном окне.

**Место для скриншота 56:** лог `terraform apply` с успешным
применением изменений.

## 6.4 Просмотр логов и аудита

### 6.4.1 Логи приложения

```bash
# Логи конкретного пода
kubectl -n default logs -l app=diplom-app --tail=100

# Логи через метку
kubectl -n default logs deploy/diplom-app --tail=100

# Слежение в реальном времени
kubectl -n default logs -f deploy/diplom-app
```

### 6.4.2 Логи Kubernetes кластера

Логи master-узлов автоматически собираются в Cloud Logging
(Logging Group `diplom-k8s-logs`). Просмотр:

**Через консоль:** Yandex Cloud → Cloud Logging → группа
`diplom-k8s-logs`. Фильтры по источнику, уровню, времени.

**Через CLI:**

```bash
yc logging read --group-id e23k081nj19htprt2eqo --since 1h
```

Примеры полезных фильтров:

```bash
# Только ошибки API-сервера
yc logging read --group-id e23k081nj19htprt2eqo --since 1h \
  --filter 'json_payload.source="kube-apiserver" and json_payload.level="error"'

# События кластера
yc logging read --group-id e23k081nj19htprt2eqo --since 1h \
  --filter 'json_payload.source="events"'
```

### 6.4.3 Аудит действий в облаке

Audit Trails пишет все управляющие события (кто что создал, изменил,
удалил) в ту же Logging Group. Просмотр через консоль:
**Audit Trails → трейл `diplom-audit-trail` → События**.

Примеры запросов для отладки:

```bash
# Кто создавал ВМ за последние сутки
yc logging read --group-id e23k081nj19htprt2eqo --since 24h \
  --filter 'json_payload.event_type="yandex.cloud.audit.compute.CreateInstance"'

# Все действия сервисного аккаунта Terraform
yc logging read --group-id e23k081nj19htprt2eqo --since 24h \
  --filter 'json_payload.authentication.subject_id="ajekv8hrk7kan34m0ou4"'
```

**Место для скриншота 57:** консоль Audit Trails с фильтром по
действиям сервисного аккаунта.

## 6.5 Диагностика типовых проблем

За время работы над проектом я столкнулся с несколькими классами
проблем. Ниже — их описание и решения.

### 6.5.1 Поды в статусе Pending

**Симптом:** под не запускается, висит в `Pending`.

**Диагностика:**

```bash
kubectl describe pod <pod-name> -n <namespace> | grep -A 20 "Events:"
```

**Типичные причины:**

- Не хватает ресурсов на узле (`Insufficient cpu/memory`).
- Не подходит `nodeSelector` или `affinity`.
- Узел имеет taint, который под не tolerates.
- PVC в статусе Pending.

**Решение зависит от причины.** Например, для нехватки ресурсов —
уменьшить requests или добавить узел.

### 6.5.2 ImagePullBackOff

**Симптом:** под не может скачать образ.

**Диагностика:**

```bash
kubectl describe pod <pod-name> | grep -A 5 "Failed"
```

**Типичные причины:**

- Отсутствует `imagePullSecret` для приватного реестра.
- Secret создан не в том namespace.
- Образ не существует в реестре.

**Решение:** создать Secret в правильном namespace:

```bash
kubectl -n default create secret docker-registry yc-registry \
  --docker-server=cr.yandex \
  --docker-username=json_key \
  --docker-password="$(cat ~/.yandex/sa-key.json)"
```

И сослаться на него в Deployment:

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: yc-registry
```

### 6.5.3 Terraform state разошёлся с реальностью

**Симптом:** `terraform plan` показывает создание ресурса, который
уже существует в облаке.

**Причина:** ресурс был создан вне Terraform (вручную через
консоль или CLI).

**Решение:** импортировать ресурс в state:

```bash
terraform import <адрес-в-конфиге> <ID-в-облаке>
```

Например:

```bash
terraform import module.observability.yandex_logging_group.k8s_logs e23k081nj19htprt2eqo
```

После импорта `terraform plan` покажет `No changes`.

### 6.5.4 Cilium не пропускает трафик между узлами

**Симптом:** под на узле A не может достучаться до пода на узле B.

**Причина:** неверный MTU на cilium_host. По умолчанию 1500, а
VXLAN добавляет 50 байт заголовков.

**Решение:**

```bash
kubectl -n kube-system patch configmap cilium-config \
  --type merge --patch '{"data": {"mtu": "1450"}}'

kubectl -n kube-system rollout restart daemonset cilium
```

После перезапуска интерфейсы `cilium_host` и `cilium_vxlan`
получат MTU 1450.

### 6.5.5 Helm upgrade завис

**Симптом:** `helm upgrade` падает с ошибкой
`another operation (install/upgrade/rollback) is in progress`.

**Причина:** предыдущая операция не завершилась, в кластере
остался lock.

**Решение:**

```bash
# Проверить статус
helm history <release> -n <namespace>
helm status <release> -n <namespace>

# Если pending-*, удалить релиз
helm uninstall <release> -n <namespace>

# Установить заново
helm install <release> <chart> -f <values> -n <namespace>
```

В workflow `k8s-helm.yml` эта проблема решена автоматически —
перед установкой workflow проверяет статус релиза и снимает
зависшие операции.

## 6.6 Резервное копирование

### 6.6.1 Terraform state

State хранится в S3 с **включённым версионированием**. Это значит:

- Каждое изменение сохраняется как новая версия.
- Можно откатиться к любой предыдущей версии.
- Восстановление: скачать нужную версию через консоль Object
  Storage и загрузить обратно.

### 6.6.2 Конфигурация кластера

Все манифесты и конфигурация лежат в Git. Даже если кластер
полностью сломается, его можно пересоздать за 15–20 минут,
применив те же манифесты.

### 6.6.3 Приложение

Исходный код в Git, Docker-образы в Container Registry. Образы
помечены тегами `sha-<commit>` и `v<semver>` — можно откатиться
к любой версии.

## 6.7 Мониторинг расходов

Yandex Cloud предоставляет сервис **Billing** с детализацией
расходов. Я периодически проверял:

- **Compute Cloud** — стоимость ВМ. Основная статья расходов,
  но прерываемые ВМ дают большую скидку.
- **Managed Kubernetes** — фиксированная плата за мастер.
- **Object Storage** — минимальная (state-файл).
- **Network Load Balancer** — небольшая, но есть.

Для экономии я использовал:

- Прерываемые ВМ для всех узлов.
- Минимальные размеры дисков (10–20 ГБ).
- Отключённые логи (retention 72 часа).
- Один NLB вместо нескольких.

**Место для скриншота 58:** график расходов в Billing
(за последний месяц).

## 6.8 Планы по развитию

Что можно улучшить в проекте:

1. **PersistentVolume для Prometheus** — через managed node group
   или Thanos sidecar с S3.
2. **Отдельные node pool** для системных подов и приложений
   (taints и tolerations).
3. **Cluster Autoscaler** для динамического масштабирования.
4. **External Secrets Operator** с Yandex Lockbox вместо GitHub
   Secrets.
5. **Argo CD** для GitOps-подхода к деплою.
6. **cert-manager** для автоматического обновления TLS.
7. **Service Mesh** (Istio или Linkerd) для observability и
   mTLS между сервисами.
8. **Секреты через SOPS** для шифрования в Git.

## 6.9 Итоги главы

- Описаны особенности работы с прерываемыми ВМ и решения
  типичных проблем (потеря IP, OOM).
- Разобраны сценарии обновления и отката приложения.
- Показано, как читать логи и аудит в Yandex Cloud.
- Собран каталог типовых проблем и решений.
- Описаны подходы к резервному копированию и мониторингу
  расходов.
