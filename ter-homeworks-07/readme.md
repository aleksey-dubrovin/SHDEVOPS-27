# Итоговый проект: Развертывание web-приложения в Yandex Cloud

[Запуск Docker-образа на виртуальной машине с помощью Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/run-docker-on-vm/terraform)

## Описание проекта
Развертывание Python web-приложения в Yandex Cloud с использованием Terraform, Docker и managed MySQL.

## Архитектура
- 2 виртуальные машины с Ubuntu 22.04 (2 CPU, 2 RAM)
- Managed MySQL кластер
- Container Registry для хранения Docker образов
- LockBox для хранения паролей
- VPC с подсетью 192.168.72.0/24

## Предварительные требования
- Установленный Terraform >= 1.5
- Аккаунт в Yandex Cloud с активированным платежным аккаунтом
- Созданный bucket в Object Storage для хранения state
- Статический ключ доступа для S3

## Развертывание

### 1. Клонирование репозитория
```bash
git clone 
cd project
