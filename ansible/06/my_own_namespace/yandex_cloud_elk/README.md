## Описание

Коллекция для домашнего задания №6.

Содержит пользовательский модуль Ansible для создания текстовых файлов на удалённых хостах.

## Модули

### my_own_module

Создаёт текстовый файл с указанным содержимым.

#### Параметры

| Параметр | Тип | Обязательный | По умолчанию | Описание |
|----------|-----|--------------|--------------|----------|
| `path` | str | ✅ да | - | Абсолютный путь к создаваемому файлу |
| `content` | str | ✅ да | - | Содержимое файла |

#### Примеры

```yaml
- name: Создать конфигурационный файл
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /etc/myapp/config.ini
    content: |
      [settings]
      debug=true
      log_level=INFO

- name: Создать временный файл
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /tmp/test.txt
    content: "Hello from Ansible module"
```

#### Возвращаемые значения

| Ключ | Тип | Описание |
|------|-----|----------|
| `changed` | bool | Было ли изменение |
| `path` | str | Путь к файлу |
| `content` | str | Записанное содержимое |

## Роли

### my_file_role

Роль-обёртка для использования `my_own_module` с настраиваемыми параметрами.

#### Переменные роли

| Имя | Значение по умолчанию | Описание |
|-----|----------------------|----------|
| `my_module_path` | `/tmp/from_role_default.txt` | Путь к создаваемому файлу |
| `my_module_content` | `"Default content from role"` | Содержимое файла |

#### Пример использования

```yaml
- name: Использовать роль с параметрами по умолчанию
  hosts: all
  roles:
    - my_file_role

- name: Использовать роль с пользовательскими параметрами
  hosts: all
  roles:
    - role: my_file_role
      vars:
        my_module_path: /opt/app/config.txt
        my_module_content: "custom config"
```

## Установка

### Из архива

```bash
ansible-galaxy collection install my_own_namespace-yandex_cloud_elk-1.0.0.tar.gz
```

### Из Git репозитория

```bash
ansible-galaxy collection install git+https://github.com/aleksey-dubrovin/SHDEVOPS-27.git
```

## Лицензия

GNU General Public License v3.0 or later

## Автор

Aleksey Dubrovin (@aleksey-dubrovin)
