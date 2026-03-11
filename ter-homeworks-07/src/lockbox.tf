# Создание LockBox секрета для пароля БД
resource "yandex_lockbox_secret" "db_secret" {
  name        = "db-password-secret"
  description = "Secret for database password"
}

# Версия секрета с паролем
resource "yandex_lockbox_secret_version" "db_secret_version" {
  secret_id = yandex_lockbox_secret.db_secret.id
  entries {
    key        = "db_password"
    text_value = var.db_password
  }
}

# Получение значения из LockBox для использования в других ресурсах
data "yandex_lockbox_secret_version" "db_password" {
  secret_id = yandex_lockbox_secret.db_secret.id
  version_id = yandex_lockbox_secret_version.db_secret_version.id
  depends_on = [yandex_lockbox_secret_version.db_secret_version]
}