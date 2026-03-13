# Получаем информацию о существующем сервисном аккаунте
data "yandex_iam_service_account" "existing_sa" {
  service_account_id = var.service_account_id != "" ? var.service_account_id : null
  name               = var.service_account_id == "" ? var.service_account_name : null
}

# Получаем информацию о текущем пользователе (опционально)
data "yandex_client_config" "client" {}