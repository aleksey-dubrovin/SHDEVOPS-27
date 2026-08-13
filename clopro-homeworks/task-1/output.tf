output "nat_public_ip" {
  value = yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address
}

output "ssh_command" {
  value = "ssh ubuntu@${yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address}"
}

output "ssh_to_client" {
  value = "ssh -p 2222 ubuntu@${yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address}"
}