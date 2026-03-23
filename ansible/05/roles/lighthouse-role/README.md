# Ansible Role: Lighthouse

Роль для установки и настройки Lighthouse — веб-интерфейса для ClickHouse.

## Требования

- Rocky Linux 9
- Доступ к интернету для клонирования репозитория

## Переменные

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `lighthouse_repo` | URL репозитория | `https://github.com/VKCOM/lighthouse.git` |
| `lighthouse_version` | Версия | `master` |
| `lighthouse_path` | Путь установки | `/var/www/lighthouse` |
| `nginx_config_path` | Путь к конфигу nginx | `/etc/nginx/conf.d/lighthouse.conf` |

## Что делает роль

1. Устанавливает nginx, git, firewalld
2. Клонирует репозиторий Lighthouse
3. Настраивает SELinux
4. Настраивает firewall
5. Запускает nginx

## Пример использования

```yaml
- name: "Настройка Lighthouse"
  hosts: lighthouse
  become: true
  gather_facts: true
  roles:
    - lighthouse-role
```

## Запуск

```bash
ansible-playbook -i inventory/inventory-prod.yml site.yml --tags lighthouse
```

## Проверка

```bash
curl http://<lighthouse-ip>/
```

## Лицензия

MIT