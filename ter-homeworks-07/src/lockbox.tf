# Создание LockBox секрета для пароля БД
resource "yandex_lockbox_secret" "db_secret" {
  name        = "db-password-secret"
  description = "Secret for database password"
}

# Назначение роли lockbox.payloadViewer сервисному аккаунту
resource "yandex_lockbox_secret_iam_binding" "secret_viewer" {
  secret_id = yandex_lockbox_secret.db_secret.id
  role      = "lockbox.payloadViewer"
  
  members = [
    "serviceAccount:${yandex_iam_service_account.terraform_sa.id}",
  ]
}

# Версия секрета с паролем
resource "yandex_lockbox_secret_version" "db_secret_version" {
  depends_on = [yandex_lockbox_secret_iam_binding.secret_viewer]
  secret_id  = yandex_lockbox_secret.db_secret.id
  
  entries {
    key        = "db_password"
    text_value = var.db_password
  }
}

# Получение значения из LockBox
data "yandex_lockbox_secret_version" "db_password" {
  secret_id  = yandex_lockbox_secret.db_secret.id
  version_id = yandex_lockbox_secret_version.db_secret_version.id
  depends_on = [yandex_lockbox_secret_version.db_secret_version]
}