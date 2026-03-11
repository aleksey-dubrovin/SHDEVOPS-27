output "vm_1_public_ip" {
  description = "Public IP of first VM"
  value       = yandex_compute_instance.app_vm_1.network_interface.0.nat_ip_address
}

output "vm_2_public_ip" {
  description = "Public IP of second VM"
  value       = yandex_compute_instance.app_vm_2.network_interface.0.nat_ip_address
}

output "mysql_host" {
  description = "MySQL host address"
  value       = yandex_mdb_mysql_cluster.app_mysql.host.0.fqdn
}

output "container_registry_id" {
  description = "Container Registry ID"
  value       = yandex_container_registry.app_registry.id
}

output "db_password_secret_id" {
  description = "LockBox secret ID for database password"
  value       = yandex_lockbox_secret.db_secret.id
}