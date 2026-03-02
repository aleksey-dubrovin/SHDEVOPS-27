data "yandex_compute_image" "debian-db" {
    image_id = var.vm_image
}

resource "yandex_compute_instance" "db" {
  for_each = {
    for vm in var.each_vm : vm.vm_name => vm
  }
  name        = each.value.vm_name
  platform_id = var.vm_web_platform
  allow_stopping_for_update = true
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
    
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian-db.image_id
      size = each.value.disk_volume
      type = each.value.hdd_type
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

  metadata = {
    ssh-keys = "debian:${local.ssh_public_key}"
}
}