# Ansible Role: Yandex Cloud Inventory Generator

Роль для автоматической генерации Ansible инвентаря на основе VM в Yandex Cloud.

## Требования

- Установленный YC CLI (`yc`)
- OAuth токен или сервисный аккаунт

## Переменные

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `inventory.file` | Путь к файлу инвентаря | `inventory/inventory-prod.yml` |
| `inventory.create_group_vars` | Создавать group_vars | `true` |
| `inventory.skip_empty_groups` | Пропускать пустые группы | `true` |
| `group_by` | Правила группировки | по labels.ansible_group, labels.role, labels.app |

## Группировка

Инвентарь автоматически создает группы:

- **По метке `ansible_group`** — группы с именами из меток
- **По ролям** — группы `role_*` на основе `labels.role`
- **Все VM** — группа `all_vms`

## Пример использования

```yaml
- name: "Генерация инвентаря"
  hosts: localhost
  connection: local
  gather_facts: true
  roles:
    - yc-inventory-role
```

## Запуск

```bash
ansible-playbook -i inventory/local.yml site.yml --tags inventory
```

## Результат

Файл `inventory/inventory-prod.yml` сгруппированными хостами.

## Лицензия

MIT