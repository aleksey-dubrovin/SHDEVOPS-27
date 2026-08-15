terraform {
  required_version = ">= 1.5.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.85.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# ======================== ОБРАЗЫ ========================

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_compute_image" "nat-instance" {
  family = "nat-instance-ubuntu-2204"
}

# ======================== СЕТЬ ========================

resource "yandex_vpc_network" "clopro" {
  name = "clopro"
}

# Публичная подсеть (NAT-инстанс)
resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Подсеть для приватной сети
resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private_subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}

# ======================== ТАБЛИЦА МАРШРУТИЗАЦИИ ========================

resource "yandex_vpc_route_table" "private_route" {
  name       = "private-route"
  network_id = yandex_vpc_network.clopro.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface[0].ip_address
  }
}

# ======================== ГРУППЫ БЕЗОПАСНОСТИ ========================

# NAT-инстанс
resource "yandex_vpc_security_group" "nat_sg" {
  name        = "nat-security-group"
  description = "Security group for NAT instance"
  network_id  = yandex_vpc_network.clopro.id

   ingress {
    protocol       = "TCP"
    description    = "SSH to NAT"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "SSH to Client (via NAT)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 2222
  }
 
  ingress {
    protocol       = "ANY"
    description    = "Allow all internal traffic"
    v4_cidr_blocks = ["192.168.20.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ВМ брокера
resource "yandex_vpc_security_group" "private_sg" {
  name        = "private-security-group"
  description = "Security group for private VM"
  network_id  = yandex_vpc_network.clopro.id

  # Весь внутренний трафик разрешён
  ingress {
    protocol       = "ANY"
    description    = "Allow all internal traffic"
    v4_cidr_blocks = ["192.168.10.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ======================== NAT-ИНСТАНС ========================

resource "yandex_compute_instance" "nat_instance" {
  name        = "nat"
  hostname    = "nat"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.nat_vm_cores
    memory = var.nat_vm_memory
    core_fraction = var.nat_vm_usage
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat-instance.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    ip_address         = "192.168.10.254" 
    nat                = true
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init-nat.tpl", {
      VM_PASSWORD = var.secure_password
      SSH_PUBLIC_KEY = file(var.public_ssh_key_path)
    })
  }

  scheduling_policy {
    preemptible = var.use_preemptible
  }
}

# ======================== ВМ1: КЛИЕНТ ========================

resource "yandex_compute_instance" "client_vm" {
  name        = "client"
  hostname    = "client"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.client_vm_cores
    memory = var.client_vm_memory
    core_fraction = var.client_vm_usage
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = var.client_vm_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    ip_address         = "192.168.20.10" 
    nat                = false
    security_group_ids = [yandex_vpc_security_group.private_sg.id]
  }

  metadata = {
        ssh-keys = "ubuntu:${file(var.public_ssh_key_path)}"
  }

  scheduling_policy {
    preemptible = var.use_preemptible
  }
}