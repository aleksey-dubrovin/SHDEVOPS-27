resource "yandex_compute_disk" "vm_storage" {
  count = 3
  name = "netology-develop-platform-vm_storage-${count.index+1}"
  type = var.vm_storage_disk_type
  size = 1
}

data "yandex_compute_image" "debian-storage" {
    image_id = var.vm_image
}

resource "yandex_compute_instance" "storage" {
  name        = "netology-develop-platform-storage"
  platform_id = var.vm_storage_platform
  
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian-storage.image_id
      size = var.vm_web_disk_size
      type = var.vm_web_disk_type
     }
  }

  dynamic secondary_disk {
    for_each = toset(yandex_compute_disk.vm_storage[*].id)
    content {
        disk_id = secondary_disk.value
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat       = true
  }

    metadata = {
     ssh-keys = "debian:${local.ssh_public_key}"
}
}