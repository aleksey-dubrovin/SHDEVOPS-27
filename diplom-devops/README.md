# Пояснительная записка к дипломной работе

**Тема:** DevOps-практикум в Yandex Cloud: инфраструктура, Kubernetes, CI/CD и мониторинг

**Выполнил:** Алексей Дубровин, студент курса «DevOps для опытных инженеров» (Netology)

**Дата:** сентябрь 2026

## Содержание

1. [Введение](01-intro.md)
2. [Глава 1. Подготовка облачной инфраструктуры](02-infrastructure.md)
3. [Глава 2. Kubernetes кластер](03-kubernetes.md)
4. [Глава 3. Тестовое приложение](04-application.md)
5. [Глава 4. Мониторинг и алертинг](05-monitoring.md)
6. [Глава 5. CI/CD](06-cicd.md)
7. [Глава 6. Эксплуатация и обслуживание](07-operations.md)
8. [Заключение](08-conclusion.md)
9. [Список литературы](09-references.md)

## Краткое резюме проекта

Проект — полностью автоматизированный DevOps-стек в Yandex Cloud:

- **Инфраструктура:** Terraform с модульной архитектурой, S3 backend, 6 модулей.
- **Kubernetes:** Managed K8s с региональным мастером и внешними worker-узлами.
- **Приложение:** nginx-сайт с автоматической сборкой через GitHub Actions.
- **Мониторинг:** Prometheus, Grafana, Alertmanager с интеграцией в MAX.
- **CI/CD:** три независимых пайплайна (инфраструктура, K8s, приложение).
- **Наблюдаемость:** Audit Trails и Cloud Logging.

## Ссылки

- [Репозиторий инфраструктуры](https://github.com/aleksey-dubrovin/devops-diplom-infra)
- [Репозиторий Kubernetes](https://github.com/aleksey-dubrovin/devops-diplom-k8s)
- [Репозиторий приложения](https://github.com/aleksey-dubrovin/devops-diplom-app)
- [Работающее приложение](https://app.dubrovins.ru)
- [Grafana](https://monitoring.dubrovins.ru)