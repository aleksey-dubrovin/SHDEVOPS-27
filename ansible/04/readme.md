## Домашнее задание к занятию 4 «Работа с roles»

1. [Ansible roles](https://galaxy.ansible.com/ui/standalone/roles/)

2. [Ansible Lint Documentation](https://docs.ansible.com/projects/lint/)

3. [Indexes of all modules and plugins](https://docs.ansible.com/projects/ansible/latest/collections/all_plugins.html)

4. [Integrating Vector with ClickHouse](https://clickhouse.com/docs/ru/integrations/vector)

### Подготовка к ваполнению

1. https://github.com/aleksey-dubrovin/vector-role

2. https://github.com/aleksey-dubrovin/lighthouse-role

3. Подготовка окружения
```bash
mkdir -p playbooks roles collections inventories && touch ansible.cfg requirements.yml .gitignore
```
### Основная часть 

1. Установка зависимостей

```bash
ansible-galaxy install -r requirements.yml -p .
ansible-galaxy collection install -r requirements.yml
```

### Роль ansible playbook для развертывания конвейера данных Vector

https://github.com/aleksey-dubrovin/vector-role.git


### Роль ansible playbook для развертывания web интерфейса для Clickhouse

https://github.com/aleksey-dubrovin/lighthouse-role.git

# Ansible Playbook: Log Platform Deployment

Полная автоматизация развертывания платформы сбора логов в Yandex Cloud:

- **ClickHouse** — база данных для хранения логов
- **Vector** — сборщик и трансформатор логов
- **Lighthouse** — веб-интерфейс для просмотра логов

## Структура проекта

```
04/
├── ansible.cfg                 # Конфигурация Ansible
├── group_vars/
│   └── all.yml                 # Глобальные переменные
├── inventory/
│   ├── local.yml               # Статический инвентарь для localhost
│   └── inventory-prod.yml      # Сгенерированный инвентарь
├── roles/
│   ├── yc-vm-role/             # Создание VM
│   ├── yc-inventory-role/      # Генерация инвентаря
│   ├── clickhouse/             # Установка ClickHouse
│   ├── vector-role/            # Установка Vector
│   └── lighthouse-role/        # Установка Lighthouse
└── site.yml                    # Главный плейбук
```

## Требования

- Ansible 2.9+
- YC CLI (`yc`)
- SSH ключ для доступа к VM

## Переменные окружения

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_FOLDER_ID=$(yc config get folder-id)
```

## Запуск

### 1. Создание инфраструктуры (VM и инвентарь)

```bash
ansible-playbook -i inventory/local.yml site.yml --tags create-vms
ansible-playbook -i inventory/local.yml site.yml --tags inventory
```

### 2. Настройка сервисов

```bash
# ClickHouse
ansible-playbook -i inventory/inventory-prod.yml site.yml --tags clickhouse

# Vector
ansible-playbook -i inventory/inventory-prod.yml site.yml --tags vector

# Lighthouse
ansible-playbook -i inventory/inventory-prod.yml site.yml --tags lighthouse
```

### 3. Полный запуск

```bash
ansible-playbook -i inventory/local.yml site.yml
```

## Проверка работы

```bash
# ClickHouse
curl http://<clickhouse-ip>:8123/

# Lighthouse
curl http://<lighthouse-ip>/

# Vector
ansible -i inventory/inventory-prod.yml vector -m shell -a "systemctl status vector"
```

## Переменные

Все переменные задаются в `group_vars/all.yml`:

- `yc_folder_id`, `yc_token` — доступ к Yandex Cloud
- `default_vm` — настройки VM по умолчанию
- `vms_to_create` — список создаваемых VM
- `inventory` — настройки генерации инвентаря

## Лицензия

MIT

## Автор

Aleksey Dubrovin
