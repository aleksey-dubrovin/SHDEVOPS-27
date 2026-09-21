
# Дипломный практикум в Yandex Cloud

Краткий отчёт о выполненной работе.

## Что сделано

Полностью развёрнут DevOps-стек в Yandex Cloud:

| Компонент | Реализация | Ссылка |
|-----------|-----------|--------|
| Инфраструктура | Terraform, 6 модулей, S3 backend | [devops-diplom-infra](https://github.com/aleksey-dubrovin/devops-diplom-infra) |
| Kubernetes | Managed K8s + 2 внешних worker-узла | [devops-diplom-k8s](https://github.com/aleksey-dubrovin/devops-diplom-k8s) |
| Приложение | nginx на `nginx:alpine` | [devops-diplom-app](https://github.com/aleksey-dubrovin/devops-diplom-app) |
| Мониторинг | Prometheus, Grafana, Alertmanager | [monitoring.dubrovins.ru](https://monitoring.dubrovins.ru) |
| CI/CD | GitHub Actions, 3 пайплайна | Actions в каждом репозитории |
| Приложение в проде | Деплой через тег | [app.dubrovins.ru](https://app.dubrovins.ru) |

## Ключевые особенности

- **Модульный Terraform** с S3 backend и версионированием state.
- **Гибридный Kubernetes**: managed мастер и внешние worker-узлы
  на прерываемых ВМ.
- **Cilium в туннельном режиме** для связи между узлами.
- **Data-driven подход** к секретам и Helm-чартам.
- **Сквозной CI/CD**: от коммита в приложении до деплоя в кластер
  через `repository_dispatch`.
- **TLS от Let's Encrypt** для `*.dubrovins.ru` через Yandex
  Certificate Manager.
- **Алертинг в MAX** через собственный Flask-сервис.
- **Audit Trails + Cloud Logging** для наблюдаемости.

## Технологический стек

Yandex Cloud, Terraform, Managed Kubernetes, Cilium, Docker,
Yandex Container Registry, Helm, kube-prometheus-stack, Prometheus,
Grafana, Alertmanager, NGINX Ingress, Network Load Balancer,
GitHub Actions, Flask.

## Документация

Полная пояснительная записка: [docs/README.md](docs/README.md)

## Ссылки на работающие сервисы

- Приложение: https://app.dubrovins.ru
- Grafana: https://monitoring.dubrovins.ru
- CI/CD: вкладка Actions в каждом репозитории

## Что можно улучшить

- PersistentVolume для Prometheus (через managed node group
  или Thanos + S3).
- External Secrets Operator с Yandex Lockbox.
- Argo CD для GitOps.
- cert-manager для автоматического продления TLS.