resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "platform" {
  name           = var.vpc_subnet[0]
  zone           = var.default_zone[0]
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.subnet_platform
}
resource "yandex_vpc_subnet" "db" {
  name           = var.vpc_subnet[1]
  zone           = var.default_zone[1]
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.subnet_db
}
data "yandex_compute_image" "ubuntu" {
  family = var.vm_image
}
resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_name
  platform_id = var.vm_web_platform
  allow_stopping_for_update = true
  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
    
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.vms_resources["web"].hdd_size
      type = var.vms_resources["web"].hdd_type 
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.platform.id
    nat       = true
  }

  metadata = {
    serial-port-enable = var.metadata["web"].serial-port-enable
    ssh-keys           = var.metadata["web"].ssh-keys
  #metadata = {
  #  serial-port-enable = 1
  #  ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}

resource "yandex_compute_instance" "db" {
  name        = local.vm_db_name
  platform_id = var.vm_db_platform
  zone = var.default_zone[1]
  allow_stopping_for_update = true
  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.vms_resources["db"].hdd_size
      type = var.vms_resources["db"].hdd_type 
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = true
  }
  metadata = {
    serial-port-enable = var.metadata["db"].serial-port-enable
    ssh-keys           = var.metadata["db"].ssh-keys
  #metadata = {
  #  serial-port-enable = 1
  #  ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}