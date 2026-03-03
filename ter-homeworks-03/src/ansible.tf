resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible_inventory.ini"
  content  = templatefile("${path.module}/inventory.tftpl", {
    web_ips   = yandex_compute_instance.web[*].network_interface[0].nat_ip_address
    web_fqdns = yandex_compute_instance.web[*].fqdn
    web_names = yandex_compute_instance.web[*].name
    
    db_ips   = values(yandex_compute_instance.db)[*].network_interface[0].nat_ip_address
    db_fqdns = values(yandex_compute_instance.db)[*].fqdn
    db_names = values(yandex_compute_instance.db)[*].name
    
    storage_ips   = yandex_compute_instance.storage[*].network_interface[0].nat_ip_address
    storage_fqdns = yandex_compute_instance.storage[*].fqdn
    storage_names = yandex_compute_instance.storage[*].name
  })
}