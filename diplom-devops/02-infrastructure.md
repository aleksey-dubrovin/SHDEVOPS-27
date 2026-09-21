# Глава 1. Подготовка облачной инфраструктуры

## 1.1 Архитектура инфраструктуры

Вся инфраструктура описана в репозитории `devops-diplom-infra`
с использованием Terraform. Проект построен по модульному принципу:
каждый компонент вынесен в отдельный модуль, а корневой
`infrastructure/main.tf` собирает их вместе.

Состояние Terraform хранится в Yandex Object Storage. Это позволило
вынести применение конфигурации в CI/CD и работать с одинаковым
окружением локально и в GitHub Actions.

Структура репозитория:

```text
devops-diplom-infra/
├── backend/                    # создание S3-бакета и сервисного аккаунта
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars        # не коммитится
├── infrastructure/             # основная инфраструктура
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf              # S3 backend
│   └── terraform.tfvars        # не коммитится
└── modules/
    ├── vpc/                    # сеть и подсети
    ├── security-group/         # правила firewall
    ├── iam/                    # сервисные аккаунты и роли
    ├── k8s-cluster/            # Managed Kubernetes
    ├── compute/                # bastion и worker-узлы
    └── observability/          # Audit Trails и Logging Group
```

**Место для скриншота 3:** дерево репозитория `devops-diplom-infra`
(можно `tree -L 2`).

## 1.2 Сервисный аккаунт и права доступа

В Yandex Cloud невозможно создать ресурсы анонимно, поэтому первым
шагом я подготовил сервисный аккаунт `avdubrovin-prod`. Он используется
в двух ролях:

1. Для Terraform — через авторизованный JSON-ключ.
2. Для самого кластера и его компонентов — через роли на уровне папки.

Задание диплома прямо указывает: «не стоит использовать права
суперпользователя». Я назначил минимальный набор ролей:

| Роль | Назначение |
|------|-----------|
| `k8s.clusters.agent` | Управление кластером |
| `k8s.tunnelClusters.agent` | Туннельный режим Cilium |
| `vpc.publicAdmin` | Публичные IP и NLB |
| `container-registry.images.puller` | Скачивание образов |
| `container-registry.admin` | Управление реестром |
| `monitoring.editor` | Отправка метрик |
| `storage.editor` | Работа с Object Storage |
| `dns.editor` | Управление DNS-зоной |
| `audit-trails.editor` | Создание трейлов аудита |

**Место для скриншота 4:** консоль Yandex Cloud, раздел IAM →
сервисный аккаунт `avdubrovin-prod` со списком ролей.

## 1.3 Backend Terraform в S3

Для хранения состояния Terraform я создал бакет в Object Storage.
Это критично для CI/CD: если state лежит только локально, GitHub Actions
не увидит ресурсы и будет пытаться создать их заново.

Конфигурация backend вынесена в отдельную папку `backend/`. В ней
Terraform создаёт:

- сервисный аккаунт (если ещё нет),
- статический ключ доступа для S3,
- бакет с версионированием.

После `terraform apply` в папке `backend/` я получил `access_key`
и `secret_key`, которые добавил в GitHub Secrets.

В папке `infrastructure/backend.tf` настроен S3 backend:

```hcl
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "devops-diplom-tf-b1glfq89j9n7quk0cnf0"
    region = "ru-central1"
    key    = "infra.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    force_path_style            = true
  }
}
```

Параметры `skip_*` обязательны при работе с S3-совместимым хранилищем,
не поддерживающим полный набор AWS API.

**Место для скриншота 5:** консоль Object Storage, бакет
`devops-diplom-tf-...` с файлом `infra.tfstate`.

## 1.4 Модуль VPC

Сетевую инфраструктуру я разделил на три типа подсетей в каждой из
трёх зон доступности. Это дало необходимую гибкость: публичные
подсети для bastion, приватные для worker-узлов, управляющие для
Managed Kubernetes.

| Назначение | ru-central1-a | ru-central1-b | ru-central1-d |
|-----------|---------------|---------------|---------------|
| Публичные | 10.0.1.0/24 | 10.0.2.0/24 | 10.0.3.0/24 |
| Приватные | 10.0.4.0/24 | 10.0.5.0/24 | 10.0.6.0/24 |
| Управляющие | 10.0.7.0/24 | 10.0.8.0/24 | 10.0.9.0/24 |

Дополнительно в модуле создаются:

- **NAT-шлюз** и таблица маршрутизации для исходящего трафика из
  приватных подсетей.
- **Приватный эндпоинт S3** — чтобы трафик к Object Storage не выходил
  в интернет и не тарифицировался как исходящий.

**Место для скриншота 6:** консоль VPC, список подсетей с CIDR и зонами.

## 1.5 Модуль Security Groups

Правила firewall описаны декларативно в модуле `security-group`. Я создал
три группы:

- `sg-bastion` — разрешает SSH (22) и ICMP из интернета.
- `sg-k8s-main` — трафик для мастера и управляемых узлов: API (443, 6443),
  kubelet (10250), etcd (2379-2380), Cilium VXLAN (8472/UDP).
- `sg-k8s-workers` — трафик для внешних узлов: SSH с bastion и мастера,
  kubelet, NodePort-диапазон, healthcheck-и NLB.

**Важный нюанс:** в группе `sg-k8s-workers` отдельно добавлено правило
с `predefined_target = "loadbalancer_healthchecks"`. Без него NLB не
может проверять состояние узлов и остаётся в статусе `INACTIVE`.

**Место для скриншота 7:** консоль Security Groups со списком правил
в группе `sg-k8s-workers`.

## 1.6 Container Registry

Для хранения Docker-образов приложения и вспомогательных сервисов я
создал Container Registry через Terraform:

```hcl
resource "yandex_container_registry" "diplom" {
  name      = "diplom-registry"
  folder_id = var.folder_id
}
```

Сервисному аккаунту назначены роли `container-registry.images.puller`
и `container-registry.images.pusher`. Это позволяет GitHub Actions
загружать образы, а worker-узлам — скачивать их через
`imagePullSecret`.

**Место для скриншота 8:** консоль Container Registry, список образов
(`devops-diplom-app`, `max-bot`).

## 1.7 Audit Trails и Logging Group

Для наблюдаемости облачных ресурсов я добавил модуль `observability`,
который создаёт два сервиса:

**Logging Group** `diplom-k8s-logs` — централизованное хранилище логов
Kubernetes-кластера. Retention — 72 часа. В группу попадают логи
kube-apiserver, события кластера, аудит API-сервера.

**Audit Trails** `diplom-audit-trail` — трейл, который пишет все
управляющие события (создание, изменение, удаление ресурсов) в ту же
Logging Group. Настроен сбор событий для всей папки.

Чтобы трейл мог собирать события, сервисному аккаунту добавлены
роли `audit-trails.editor` на папку и `audit-trails.viewer` на организацию.

**Место для скриншота 9:** консоль Cloud Logging, группа
`diplom-k8s-logs` с записями.

**Место для скриншота 10:** консоль Audit Trails, трейл
`diplom-audit-trail` со списком событий.

## 1.8 Применение инфраструктуры через CI/CD

Все изменения инфраструктуры применяются через GitHub Actions.
Workflow `.github/workflows/infrastructure.yml` запускается при пуше
в `main` и выполняет:

1. Проверка кода (`terraform fmt`, `terraform validate`).
2. Инициализация с S3 backend.
3. `terraform plan` (публикуется в PR).
4. `terraform apply` (только для main).

Секреты передаются через GitHub Secrets:

- `YC_SERVICE_ACCOUNT_KEY_B64` — JSON-ключ сервисного аккаунта
- `YC_ACCESS_KEY`, `YC_SECRET_KEY` — для S3 backend
- `YC_CLOUD_ID`, `YC_FOLDER_ID`, `TF_BUCKET_NAME`

**Место для скриншота 11:** вкладка Actions на GitHub, успешный запуск
`Deploy Infrastructure`.

**Место для скриншота 12:** вывод `terraform plan` из логов workflow.

## 1.9 Использованные приёмы

- **Модульная архитектура.** Каждый компонент — отдельный модуль
  с собственными `variables.tf` и `outputs.tf`. Это упрощает
  поддержку и позволяет переиспользовать модули.
- **Никакого хардкода.** Идентификаторы папок, ключи, пути —
  всё передаётся через переменные или GitHub Secrets.
- **Версионирование state.** Object Storage настроен с версионированием,
  что даёт возможность откатиться к предыдущему состоянию.
- **Кэширование в CI.** В workflows кэшируются Terraform-провайдеры,
  YC CLI и kubectl. Это ускорило запуски в 2–3 раза.
