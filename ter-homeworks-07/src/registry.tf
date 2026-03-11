# Создание Container Registry
resource "yandex_container_registry" "app_registry" {
  name = "app-registry"
  folder_id = var.yc_folder_id
}