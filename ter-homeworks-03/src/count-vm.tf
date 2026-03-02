data "yandex_compute_image" "debian-web" {
    image_id = var.vm_image
}

resource "yandex_compute_instance" "web" {
  count = 2
  name        = "netology-develop-platform-web-${count.index+1}"
  platform_id = var.vm_web_platform
  allow_stopping_for_update = true

  depends_on = [ yandex_compute_instance.db ]
  
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian-web.image_id
      size = var.vm_web_disk_size
      type = var.vm_web_disk_type
     }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat       = true
  }

  metadata = var.metadata_map["metadata"]
}