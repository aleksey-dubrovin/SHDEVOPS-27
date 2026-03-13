# Создание LockBox секрета для пароля БД
resource "yandex_lockbox_secret" "db_secret" {
  name        = "shvirtd-db-secret"
  description = "Database credentials for shvirtd application"
  folder_id   = var.yc_folder_id
  
  labels = {
    environment = "production"
    application = "shvirtd"
    managed_by  = "terraform"
  }
}

# Версия секрета с паролем
resource "yandex_lockbox_secret_version" "db_secret_version" {
  secret_id = yandex_lockbox_secret.db_secret.id
  
  entries {
    key        = "db_password"
    text_value = var.db_password
  }
  
  entries {
    key        = "db_user"
    text_value = var.db_user
  }
  
  entries {
    key        = "db_name"
    text_value = var.db_name
  }
}

# Назначение прав на чтение секрета существующему сервисному аккаунту
resource "yandex_lockbox_secret_iam_binding" "sa_secret_reader" {
  secret_id = yandex_lockbox_secret.db_secret.id
  role      = "lockbox.payloadViewer"
  
  members = [
    "serviceAccount:${data.yandex_iam_service_account.existing_sa.id}",
  ]
}

# Получение данных из LockBox (для использования в других ресурсах)
data "yandex_lockbox_secret_version" "db_credentials" {
  secret_id  = yandex_lockbox_secret.db_secret.id
  version_id = yandex_lockbox_secret_version.db_secret_version.id
  
  depends_on = [yandex_lockbox_secret_version.db_secret_version]
}