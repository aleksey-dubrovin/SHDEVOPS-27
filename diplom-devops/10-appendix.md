# Приложения

## Приложение A. Репозитории проекта

| Репозиторий | Назначение | URL |
|-------------|-----------|-----|
| `devops-diplom-infra` | Инфраструктура (Terraform) | https://github.com/aleksey-dubrovin/devops-diplom-infra |
| `devops-diplom-k8s` | Kubernetes конфигурация и Helm | https://github.com/aleksey-dubrovin/devops-diplom-k8s |
| `devops-diplom-app` | Тестовое приложение и CI/CD | https://github.com/aleksey-dubrovin/devops-diplom-app |

## Приложение B. Работающие сервисы

| Сервис | URL | Доступ |
|--------|-----|--------|
| Тестовое приложение | https://app.dubrovins.ru | Публичный |
| Grafana | https://monitoring.dubrovins.ru | admin / пароль из GitHub Secrets |
| Prometheus | port-forward 9090 | Внутренний |
| Alertmanager | port-forward 9093 | Внутренний |

## Приложение C. Список скриншотов

### Инфраструктура

- **Скриншот 1.** Общая схема проекта (draw.io / Excalidraw)
- **Скриншот 2.** Три открытых репозитория на GitHub
- **Скриншот 3.** Дерево репозитория `devops-diplom-infra` (`tree -L 2`)
- **Скриншот 4.** Консоль IAM, сервисный аккаунт `avdubrovin-prod` со списком ролей
- **Скриншот 5.** Консоль Object Storage, бакет с `infra.tfstate`
- **Скриншот 6.** Консоль VPC, список подсетей
- **Скриншот 7.** Консоль Security Groups, правила `sg-k8s-workers`
- **Скриншот 8.** Консоль Container Registry, список образов
- **Скриншот 9.** Консоль Cloud Logging, группа `diplom-k8s-logs`
- **Скриншот 10.** Консоль Audit Trails, трейл со списком событий
- **Скриншот 11.** GitHub Actions, успешный `Deploy Infrastructure`
- **Скриншот 12.** Лог `terraform plan` из workflow

### Kubernetes

- **Скриншот 13.** Консоль Managed Kubernetes, кластер `diplom-k8s`
- **Скриншот 14.** Мастер-локации в трёх зонах
- **Скриншот 15.** `kubectl get pods -n kube-system` с cilium
- **Скриншот 16.** Консоль Compute Cloud, три ВМ
- **Скриншот 17.** `kubectl get nodes` с двумя Ready
- **Скриншот 18.** `kubectl get pods -n kube-system` на внешних узлах
- **Скриншот 19.** `ssh diplom-worker-a "hostname"`
- **Скриншот 20.** `kubectl get svc -n ingress-nginx`
- **Скриншот 21.** Консоль NLB, target group с двумя HEALTHY
- **Скриншот 22.** Содержимое `config/secrets/registry.yaml`
- **Скриншот 23.** `kubectl get secrets -A | grep -v kube-`

### Приложение

- **Скриншот 24.** Репозиторий `devops-diplom-app` на GitHub
- **Скриншот 25.** Страница `https://app.dubrovins.ru`
- **Скриншот 26.** Содержимое `app/Dockerfile`
- **Скриншот 27.** Консоль Container Registry, образы
- **Скриншот 28.** `yc container image list --registry-id ...`
- **Скриншот 29.** Actions, workflow `Build and Push`
- **Скриншот 30.** Лог шага `Build and push`
- **Скриншот 31.** Actions, workflow `Release`
- **Скриншот 32.** Лог шага `Trigger deploy`
- **Скриншот 33.** GitHub Secrets в `devops-diplom-app`

### Мониторинг

- **Скриншот 34.** Схема стека мониторинга
- **Скриншот 35.** Содержимое `helm/monitoring-values.yaml`
- **Скриншот 36.** `kubectl get pods -n monitoring -o wide`
- **Скриншот 37.** Grafana в браузере с зелёным замком
- **Скриншот 38.** `openssl s_client` с цепочкой сертификатов
- **Скриншот 39.** Дашборд Kubernetes / Compute Resources / Cluster
- **Скриншот 40.** Дашборд Node Exporter / Nodes
- **Скриншот 41.** Prometheus UI, Status → Targets
- **Скриншот 42.** Config Alertmanager с ресивером `max-bot`
- **Скриншот 43.** Уведомление в MAX
- **Скриншот 44.** Логи max-bot с `Message sent to MAX`

### CI/CD

- **Скриншот 45.** Схема пайплайнов
- **Скриншот 46.** Actions, `Deploy Infrastructure`
- **Скриншот 47.** Diff в PR от terraform plan
- **Скриншот 48.** Содержимое `config/secrets/registry.yaml`
- **Скриншот 49.** Лог `K8s Config` со списком Secret'ов
- **Скриншот 50.** Содержимое `helm/charts.yaml`
- **Скриншот 51.** Лог `K8s Helm` с установкой чартов
- **Скриншот 52.** Лог `Deploy App` с envsubst
- **Скриншот 53.** Параллельные запуски `Release` и `Deploy App`

### Эксплуатация

- **Скриншот 54.** `kubectl top nodes`
- **Скриншот 55.** Ручной `Deploy App` с версией `v0.1.0`
- **Скриншот 56.** Лог `terraform apply`
- **Скриншот 57.** Audit Trails с фильтром
- **Скриншот 58.** График расходов в Billing

## Приложение D. Команды для проверки

### Кластер

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info
```

### Мониторинг

```bash
kubectl -n monitoring get pods
kubectl -n monitoring get svc
kubectl -n monitoring logs deploy/max-bot --tail=30
```

### Приложение

```bash
curl -I https://app.dubrovins.ru
curl -I https://monitoring.dubrovins.ru
```

### Terraform

```bash
cd devops-diplom-infra/infrastructure
terraform state list
terraform output
```

## Приложение E. Структура файлов проекта

### devops-diplom-infra

```
devops-diplom-infra/
├── backend/
├── infrastructure/
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── templates/
└── modules/
    ├── vpc/
    ├── security-group/
    ├── iam/
    ├── k8s-cluster/
    ├── compute/
    └── observability/
```

### devops-diplom-k8s

```
devops-diplom-k8s/
├── config/
│   ├── app/
│   ├── ingress/
│   ├── secrets/
│   └── service/
├── external-nodes/
├── helm/
│   ├── charts.yaml
│   ├── ingress-nginx-values.yaml
│   └── monitoring-values.yaml
├── monitoring/
│   ├── alertmanager.yaml
│   └── prometheus-rules.yaml
└── .github/workflows/
    ├── deploy.yml
    ├── k8s-apply.yml
    ├── k8s-config.yml
    └── k8s-helm.yml
```

### devops-diplom-app

```
devops-diplom-app/
├── app/
│   ├── Dockerfile
│   └── index.html
├── docs/
│   ├── README.md
│   ├── 01-intro.md
│   ├── 02-infrastructure.md
│   ├── 03-kubernetes.md
│   ├── 04-application.md
│   ├── 05-monitoring.md
│   ├── 06-cicd.md
│   ├── 07-operations.md
│   ├── 08-conclusion.md
│   ├── 09-references.md
│   └── 10-appendix.md
├── .github/workflows/
│   ├── build.yml
│   └── release.yml
└── README.md