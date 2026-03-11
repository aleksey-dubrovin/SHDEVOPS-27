# Создание сервисного аккаунта
resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "Service account for Terraform"
}

# Назначение ролей на папку
resource "yandex_resourcemanager_folder_iam_member" "sa_roles" {
  for_each = toset([
    "editor",
    "lockbox.payloadViewer",  # Добавлено явно
    "lockbox.viewer",         # Добавлено явно
    "container-registry.images.puller",
    "vpc.user"
  ])
  
  folder_id = var.yc_folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# Статический ключ для Terraform
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Static access key for Terraform"
}

# Вывод ключей
output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  sensitive = true
}

output "secret_key" {
  value = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  sensitive = true
}