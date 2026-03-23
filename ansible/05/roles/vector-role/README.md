# Ansible Role: Vector

Роль для установки и настройки Vector — легковесного сборщика логов.

## Требования

- Rocky Linux 9
- Доступ к интернету для скачивания RPM пакета

## Переменные

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `vector_version` | Версия Vector | `0.21.0` |
| `vector_config_path` | Путь к конфигурации | `/etc/vector/vector.yaml` |
| `clickhouse_host` | Хост ClickHouse | `clickhouse-01` |
| `clickhouse_port` | Порт ClickHouse | `8123` |
| `clickhouse_database` | База данных | `logs` |
| `clickhouse_table` | Таблица | `syslog` |

## Источники (sources)

По умолчанию собирает логи из:
- `/var/log/messages`
- `/var/log/secure`

## Трансформации (transforms)

Парсит syslog и добавляет поле `host`.

## Стоки (sinks)

Отправляет данные в ClickHouse.

## Пример использования

```yaml
- name: "Настройка Vector"
  hosts: vector
  become: true
  gather_facts: true
  roles:
    - vector-role
  vars:
    clickhouse_host: "192.168.172.21"
```

## Запуск

```bash
ansible-playbook -i inventory/inventory-prod.yml site.yml --tags vector
```

## Лицензия

MIT