output "nat_public_ip" {
  value = yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address
}

output "ssh_command" {
  value = "ssh ubuntu@${yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address}"
}

output "ssh_to_client" {
  value = "ssh -p 2222 ubuntu@${yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address}"
}

output "bucket_name" {
  value = yandex_storage_bucket.images.bucket
}

output "image_url" {
  value = "https://storage.yandexcloud.net/${yandex_storage_bucket.images.bucket}/picture.jpg"
}

# Ссылка на ALB через NAT (порт 80)
output "alb_url" {
  value = "http://${yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address}/"
}
