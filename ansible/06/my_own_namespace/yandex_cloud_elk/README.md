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
