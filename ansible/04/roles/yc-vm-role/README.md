# Ansible Role: Yandex Cloud VM Creator

Роль для создания виртуальных машин в Yandex Cloud с использованием YC CLI.

## Требования

- Установленный YC CLI (`yc`)
- OAuth токен или сервисный аккаунт
- Существующая подсеть в Yandex Cloud

## Переменные

### Основные переменные

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `yc_folder_id` | ID папки в Yandex Cloud | из environment |
| `yc_token` | OAuth токен | из environment |
| `vms_to_create` | Список VM для создания | [] |
| `default_vm` | Настройки по умолчанию | см. ниже |

### Настройки по умолчанию

```yaml
default_vm:
  zone: "ru-central1-b"
  subnet_name: "net-ru-central1-b"
  image_family: "rocky-9-oslogin"
  ssh_key_path: "~/.ssh/aleksey"
  vm_user: "rocky"
  platform_id: "standard-v3"
  cores: 2
  memory: 1
  core_fraction: 20
  disk_size: 10
  disk_type: "network-hdd"
  assign_public_ip: true
  preemptible: true
```

## Пример использования

```yaml
- name: "Создание VM"
  hosts: localhost
  connection: local
  gather_facts: true
  roles:
    - yc-vm-role
```

## Запуск

```bash
ansible-playbook -i inventory/local.yml site.yml --tags create-vms
```

## Лицензия

MIT