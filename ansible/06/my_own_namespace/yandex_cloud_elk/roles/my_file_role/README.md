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