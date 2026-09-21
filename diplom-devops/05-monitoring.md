
# Глава 4. Мониторинг и алертинг

## 4.1 Общая архитектура системы мониторинга

Для наблюдаемости кластера и приложений я развернул стек
`kube-prometheus-stack` — это готовый набор Helm-чартов,
включающий Prometheus Operator и все необходимые компоненты:

| Компонент | Назначение |
|-----------|-----------|
| Prometheus Operator | Управление жизненным циклом Prometheus и Alertmanager |
| Prometheus | Сбор и хранение метрик |
| Alertmanager | Обработка алертов и отправка уведомлений |
| Grafana | Визуализация метрик и дашборды |
| node-exporter | Метрики уровня операционной системы |
| kube-state-metrics | Метрики объектов Kubernetes |
| PrometheusRule | Правила алертов (CRD) |
| ServiceMonitor | Описание целей для сбора метрик (CRD) |

Такой набор покрывает все уровни наблюдаемости: от железа до
приложений. Все метрики доступны в едином интерфейсе Grafana.

**Место для скриншота 34:** схема стека мониторинга. Prometheus
собирает метрики с targets, Alertmanager обрабатывает алерты,
Grafana отображает дашборды, max-bot получает webhook.

## 4.2 Развёртывание через Helm

Установка стека выполняется через Helm в workflow `k8s-helm.yml`.
Values-файл `helm/monitoring-values.yaml` содержит всю конфигурацию.

### Особенности установки

Стандартная установка `kube-prometheus-stack` предполагает создание
PersistentVolumeClaims для Prometheus, Alertmanager и Grafana. Однако
наши worker-узлы — внешние, и **облачные диски к ним не подключаются**.
CSI-драйвер Yandex Cloud не может определить зону для внешнего узла,
PVC остаются в статусе `Pending`, поды не запускаются.

Я решил эту проблему двумя способами:

1. **Отключил PVC полностью** — Prometheus и Alertmanager используют
   `emptyDir`, Grafana хранит данные в поде. Это компромисс: метрики
   теряются при пересоздании пода, но для дипломного проекта
   приемлемо.
2. **Уменьшил retention Prometheus до 4 часов** — чтобы не забивать
   `emptyDir` (размер ограничен размером диска узла).

Пример конфигурации:

```yaml
prometheus:
  prometheusSpec:
    retention: 4h
    retentionSize: "2GB"
    storageSpec: {}
    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 800m
        memory: 1Gi

grafana:
  enabled: true
  admin:
    existingSecret: grafana-admin
    userKey: admin-user
    passwordKey: admin-password
  persistence:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 768Mi

alertmanager:
  enabled: true
  alertmanagerSpec:
    storage: {}
    configSecret: alertmanager-config
```

**Место для скриншота 35:** содержимое
`helm/monitoring-values.yaml`.

## 4.3 Распределение подов по узлам

После первого развёртывания все компоненты мониторинга оказались
на одном узле. Это вызвало OOM-killer: Grafana была убита из-за
нехватки памяти. Я решил проблему двумя шагами.

### Шаг 1. Topology Spread Constraints

Для каждого компонента добавлены ограничения на размещение:

```yaml
prometheus:
  prometheusSpec:
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app.kubernetes.io/instance: prometheus
```

`ScheduleAnyway` — мягкое требование: scheduler старается распределить
поды, но не блокирует запуск, если не может.

### Шаг 2. Pod Anti-Affinity

Дополнительно для пар Grafana↔Prometheus и Alertmanager↔Prometheus
добавлен `podAntiAffinity` с weight 100. Это гарантирует, что
тяжёлые компоненты не окажутся на одном узле.

```yaml
grafana:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/name: prometheus
            topologyKey: kubernetes.io/hostname
```

В результате после обновления Grafana и Prometheus оказались на
разных узлах, нагрузка выровнялась (46% и 63% memory limits вместо
83% и 23%). Grafana перестала падать.

**Место для скриншота 36:** вывод `kubectl get pods -n monitoring -o wide`
с распределением подов по двум узлам.

## 4.4 Grafana с HTTPS

Grafana доступна по адресу `https://monitoring.dubrovins.ru`.

### Ingress

Ingress-ресурс описан в `config/ingress/grafana.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - monitoring.dubrovins.ru
      secretName: wildcard-dubrovins-tls
  rules:
    - host: monitoring.dubrovins.ru
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-grafana
                port:
                  number: 80
```

### TLS-сертификат

Сертификат `*.dubrovins.ru` выпущен в Yandex Certificate Manager
и загружен в кластер как Secret `wildcard-dubrovins-tls`. Загрузка
выполняется workflow `k8s-config.yml` из GitHub Secrets
`WILDCARD_TLS_CRT` и `WILDCARD_TLS_KEY`.

### Одна из проблем, которую пришлось решать

После применения Ingress с аннотацией
`nginx.ingress.kubernetes.io/configuration-snippet` сервер отдавал
fake-сертификат. Оказалось, что начиная с версии ingress-nginx 1.9.0
эта аннотация запрещена из-за безопасности и контроллер **молча
пропускает** Ingress с ней. Убрав аннотацию, я получил рабочий HTTPS.

**Место для скриншота 37:** браузер с `https://monitoring.dubrovins.ru`,
зелёный замок и страница логина Grafana.

**Место для скриншота 38:** вывод
`openssl s_client -connect monitoring.dubrovins.ru:443` с цепочкой
сертификатов.

## 4.5 Дашборды Grafana

После авторизации в Grafana доступны готовые дашборды:

- **Kubernetes / Compute Resources / Cluster** — общая загрузка кластера.
- **Kubernetes / Compute Resources / Node** — состояние узлов.
- **Kubernetes / Compute Resources / Pod** — потребление ресурсов подами.
- **Kubernetes / Networking** — сетевая активность.
- **Node Exporter / Nodes** — метрики железа.

Эти дашборды поставляются вместе с `kube-prometheus-stack` и
автоматически подхватываются. Они позволяют увидеть в реальном
времени состояние всего кластера.

**Место для скриншота 39:** дашборд
`Kubernetes / Compute Resources / Cluster`.

**Место для скриншота 40:** дашборд `Node Exporter / Nodes`
с метриками CPU и памяти.

## 4.6 Prometheus UI

Prometheus доступен через port-forward для отладки:

```bash
kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
```

По адресу `http://localhost:9090` можно:

- Проверить статус targets (Status → Targets).
- Посмотреть активные алерты (Alerts).
- Выполнить PromQL-запросы (Graph).

**Место для скриншота 41:** страница `Status → Targets` в Prometheus
со всеми targets в статусе `UP`.

## 4.7 Alertmanager и интеграция с MAX

### 4.7.1 Проблема с конфигурацией Alertmanager

Изначально я настраивал Alertmanager через блок `config:` в
values-файле Helm-чарта. Однако в версии `kube-prometheus-stack`
91.4.1 этот способ **не работает**: chart принимает значения, но не
передаёт их оператору. Config внутри пода оставался дефолтным —
только ресивер `null`.

После нескольких попыток и чтения исходников chart выяснилось, что
правильный подход — использовать **`configSecret`**: указать оператору
имя Secret с готовым config.

### 4.7.2 Файл конфигурации

Config Alertmanager вынесен в отдельный файл
`monitoring/alertmanager.yaml`:

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'max-bot'
  group_by: ['alertname', 'namespace', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

receivers:
  - name: 'max-bot'
    webhook_configs:
      - url: 'http://max-bot.monitoring.svc.cluster.local:8080/webhook'
        send_resolved: true
```

Параметры группировки:

- **`group_wait: 30s`** — пауза перед отправкой первой групповой
  нотификации.
- **`group_interval: 5m`** — интервал между отправками одной группы.
- **`repeat_interval: 4h`** — повтор для нерешённого алерта.
- **`send_resolved: true`** — уведомление при разрешении проблемы.

### 4.7.3 Применение через workflow

Workflow `k8s-config.yml` создаёт Secret `alertmanager-config` из
файла `monitoring/alertmanager.yaml`:

```yaml
- name: Create Alertmanager Config Secret
  run: |
    SRC=monitoring/alertmanager.yaml
    kubectl -n monitoring create secret generic alertmanager-config \
      --from-file=alertmanager.yaml="$SRC" \
      --dry-run=client -o yaml | kubectl apply -f -
```

Файл на диске называется `alertmanager.yaml`, а внутри Secret ключ
тоже `alertmanager.yaml` — этого требует Prometheus Operator.

В `monitoring-values.yaml` указывается ссылка на этот Secret:

```yaml
alertmanager:
  alertmanagerSpec:
    configSecret: alertmanager-config
```

После применения config перезапускается под Alertmanager, и он
начинает использовать новые ресиверы.

### 4.7.4 Проверка интеграции

Проверка config внутри пода:

```bash
kubectl -n monitoring exec -it alertmanager-prometheus-kube-prometheus-alertmanager-0 \
  -c alertmanager -- sh -c "cat /etc/alertmanager/config_out/alertmanager.env.yaml | grep -A 15 'receivers:'"
```

В выводе виден ресивер `max-bot` с URL webhook:

```
receivers:
- name: max-bot
  webhook_configs:
  - send_resolved: true
    url: http://max-bot.monitoring.svc.cluster.local:8080/webhook
```

**Место для скриншота 42:** вывод команды с ресивером `max-bot`.

## 4.8 MAX Bot

### 4.8.1 Назначение

MAX Bot — это небольшой Flask-сервис, который принимает webhook
от Alertmanager и пересылает уведомления в мессенджер MAX
(аналог Telegram для российского рынка). Я использовал готовый
образ `max-bot`, собранный заранее.

### 4.8.2 Логика работы

Код сервиса (`app.py`, полный код в репозитории):

1. Принимает POST-запрос на `/webhook` в формате Alertmanager.
2. Разбирает JSON с алертами.
3. Формирует текстовое сообщение: название алерта, severity,
   summary, description, instance.
4. Отправляет сообщение через MAX API
   (`https://platform-api.max.ru/messages`).
5. Возвращает 200 OK — Alertmanager помечает алерт как доставленный.

Также есть эндпоинт `/health` для проверки живости.

### 4.8.3 Развёртывание в Kubernetes

MAX Bot развёрнут в namespace `monitoring` (чтобы Alertmanager
мог обращаться к нему по короткому имени `max-bot`). Манифест
`config/app/max-bot.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: max-bot
  namespace: monitoring
spec:
  replicas: 1
  template:
    spec:
      imagePullSecrets:
        - name: yc-registry
      containers:
        - name: max-bot
          image: ${REGISTRY_URL}/${MAX_BOT_IMAGE_NAME}:latest
          env:
            - name: MAX_BOT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: max-bot-secret
                  key: max-bot-token
            - name: MAX_CHAT_ID
              valueFrom:
                secretKeyRef:
                  name: max-bot-secret
                  key: max-chat-id
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
```

Секрет `max-bot-secret` создаётся workflow `k8s-config.yml`
из GitHub Secrets `MAX_BOT_TOKEN` и `MAX_CHAT_ID`.

### 4.8.4 Проверка доставки

Для проверки я применил тестовое правило алерта
`monitoring/prometheus-rules.yaml` с `expr: vector(1) == 1`.
Оно срабатывает всегда, и Alertmanager отправляет его в MAX.

Логи max-bot подтвердили успешную цепочку:

```
INFO:max-bot:Webhook received from Alertmanager
INFO:max-bot:Sending to MAX...
INFO:max-bot:Message sent to MAX
INFO:werkzeug:10.112.1.90 - - [21/Sep/2026 11:20:58] "POST /webhook HTTP/1.1" 200 -
```

**Место для скриншота 43:** уведомление в MAX с текстом алерта
(`Prometheus Alert / Alert: TestWarningAlert`).

**Место для скриншота 44:** логи max-bot с записями
`Message sent to MAX`.

## 4.9 PrometheusRule

Правила алертов описываются через CRD `PrometheusRule`. Для
дипломного проекта я подготовил два правила:

1. **Тестовое** — срабатывает всегда, используется для проверки
   интеграции (можно удалить перед финальной сдачей).
2. **Инфраструктурное** — например, `up == 0` — срабатывает,
   когда Prometheus не может собрать метрики с target.

Пример из `monitoring/prometheus-rules.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: test-alerts
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
    - name: test
      interval: 30s
      rules:
        - alert: TestWarningAlert
          expr: vector(1) == 1
          for: 1m
          labels:
            severity: warning
          annotations:
            summary: "Тестовый WARNING алерт"
            description: "Проверка доставки уведомлений в MAX Bot"
```

Важно: лейбл `release: prometheus` обязателен — Prometheus Operator
по умолчанию ищет PrometheusRule только с этим лейблом.

## 4.10 Итоги главы

- Развёрнут полный стек kube-prometheus-stack в namespace `monitoring`.
- Grafana доступна по HTTPS на `monitoring.dubrovins.ru`.
- Alertmanager настроен через `configSecret` (правильный подход для
  версии 91.4.1).
- MAX Bot принимает webhook и пересылает уведомления в MAX.
- Проведена проверка сквозного сценария: алерт → Alertmanager →
  MAX Bot → MAX.
- Поды мониторинга распределены по двум узлам для устранения OOM.
