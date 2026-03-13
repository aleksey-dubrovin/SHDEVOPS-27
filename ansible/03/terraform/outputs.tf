output "clickhouse_public_ip" {
  description = "Public IP of ClickHouse VM"
  value       = yandex_compute_instance.clickhouse.network_interface.0.nat_ip_address
}

output "clickhouse_private_ip" {
  description = "Private IP of ClickHouse VM"
  value       = yandex_compute_instance.clickhouse.network_interface.0.ip_address
}

output "vector_public_ip" {
  description = "Public IP of Vector VM"
  value       = yandex_compute_instance.vector.network_interface.0.nat_ip_address
}

output "vector_private_ip" {
  description = "Private IP of Vector VM"
  value       = yandex_compute_instance.vector.network_interface.0.ip_address
}

output "lighthouse_public_ip" {
  description = "Public IP of Lighthouse VM"
  value       = yandex_compute_instance.lighthouse.network_interface.0.nat_ip_address
}

output "lighthouse_private_ip" {
  description = "Private IP of Lighthouse VM"
  value       = yandex_compute_instance.lighthouse.network_interface.0.ip_address
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "service_account_id" {
  description = "Service account ID used for VMs"
  value       = var.service_account_id
}

output "service_account_key" {
  description = "Static access key for service account"
  value       = var.use_existing_sa ? yandex_iam_service_account_static_access_key.sa_static_key.access_key : null
  sensitive   = true
}

output "service_account_secret" {
  description = "Secret key for service account"
  value       = var.use_existing_sa ? yandex_iam_service_account_static_access_key.sa_static_key.secret_key : null
  sensitive   = true
}