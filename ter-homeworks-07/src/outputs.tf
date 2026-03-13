# Информация о сервисном аккаунте
output "service_account_info" {
  description = "Information about the service account"
  value = {
    id        = data.yandex_iam_service_account.existing_sa.id
    name      = data.yandex_iam_service_account.existing_sa.name
    folder_id = data.yandex_iam_service_account.existing_sa.folder_id
  }
}

# Список ролей, которые мы добавили
output "added_roles" {
  description = "Roles added to the service account"
  value = [
    "container-registry.images.puller",
    "lockbox.payloadViewer",
    "compute.viewer",
    "storage.editor"
  ]
}
# Публичный IP виртуальной машины
output "vm_public_ip" {
  description = "Public IP of the application VM"
  value       = yandex_compute_instance.app_vm.network_interface.0.nat_ip_address
}

# Адрес MySQL хоста
output "mysql_host" {
  description = "MySQL host address"
  value       = yandex_mdb_mysql_cluster.app_mysql.host.0.fqdn
}

# ID Container Registry
output "container_registry_id" {
  description = "Container Registry ID"
  value       = yandex_container_registry.app_registry.id
}

# URL для доступа к приложению
output "app_url" {
  description = "URL to access the application"
  value       = "http://${yandex_compute_instance.app_vm.network_interface.0.nat_ip_address}"
}