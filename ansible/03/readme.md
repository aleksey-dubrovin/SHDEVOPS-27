## Домашнее задание к занятию 3 «Использование Ansible»

1. [Использование сервисного аккаунта с профилем OS Login для управления ВМ с помощью Ansible](https://yandex.cloud/ru/docs/organization/tutorials/sa-oslogin-ansible)
2. [ansible-module-yandex-cloud](https://github.com/arenadata/ansible-module-yandex-cloud)
3. [Динамический inventory](https://github.com/st8f/community.general/blob/yc_compute/plugins/inventory/yc_compute.py)
4. [Index of all Inventory Plugins](https://docs.ansible.com/projects/ansible/latest/collections/index_inventory.html)

### Подготовка к выполнению

1. 
2. 
3. 

### Основная часть


# Ansible Playbook для развертывания стека ClickHouse + Vector + Lighthouse

## Описание

Данный playbook автоматизирует развертывание и настройку стека для сбора и визуализации логов:
- **ClickHouse** - колоночная СУБД для хранения логов
- **Vector** - инструмент для сбора и транспортировки логов
- **Lighthouse** - веб-интерфейс для визуализации данных из ClickHouse
- **Nginx** - веб-сервер для Lighthouse

## Архитектура

Playbook разворачивает три отдельных сервера:
- `clickhouse-01` - сервер БД (ClickHouse)
- `vector-01` - сервер сбора логов (Vector)
- `lighthouse-01` - веб-сервер с Lighthouse и Nginx

## Требования

- Ansible >= 2.14
- Python >= 3.6 на целевых хостах
- Доступ по SSH к хостам (настроенный в inventory)
- CentOS 7/8 или RedOS 7/8 на целевых хостах

## Параметры

### ClickHouse
| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `clickhouse_version` | Версия ClickHouse | 22.3.3.44 |
| `clickhouse_database` | Имя базы данных | logs |
| `clickhouse_packages` | Список пакетов | clickhouse-client, clickhouse-server, clickhouse-common-static |

### Vector
| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `vector_version` | Версия Vector | 0.21.0 |
| `vector_config` | Конфигурация Vector | (см. group_vars/vector/vars.yml) |

### Lighthouse
| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `lighthouse_repo` | URL репозитория Lighthouse | https://github.com/VKCOM/lighthouse.git |
| `lighthouse_path` | Путь установки Lighthouse | /var/www/lighthouse |

## Теги

Playbook поддерживает следующие теги для выборочного запуска:

| Тег | Описание |
|-----|----------|
| `clickhouse` | Только установка и настройка ClickHouse |
| `vector` | Только установка и настройка Vector |
| `lighthouse` | Только установка и настройка Lighthouse |
| `nginx` | Только настройка Nginx |
| `packages` | Только установка пакетов |
| `configure` | Только конфигурация сервисов |
| `verify` | Только проверка работоспособности |

## Использование

### Установка зависимостей
```bash
ansible-galaxy collection install -r requirements.yml