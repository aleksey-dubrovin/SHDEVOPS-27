## Synopsis

Creates a text file on a remote host with specified content.

## Parameters

| Parameter | Type | Required | Default | Choices | Description |
|-----------|------|----------|---------|---------|-------------|
| path | str | yes | - | - | Absolute path to the file to be created |
| content | str | yes | - | - | Content to write into the file |

## Examples

```yaml
- name: Create a simple file
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /tmp/example.txt
    content: "Hello, World!"

- name: Create a multi-line file
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /tmp/config.ini
    content: |
      [database]
      host=localhost
      port=5432
```

## Return Values

| Key | Type | Returned | Description |
|-----|------|----------|-------------|
| changed | bool | always | True if the file was created or modified |
| path | str | always | Path to the target file |
| content | str | always | Content that was written |
