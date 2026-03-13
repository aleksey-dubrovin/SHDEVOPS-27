# Создание VPC сети
resource "yandex_vpc_network" "network" {
  name        = "logs-platform-network"
  description = "Network for logs platform"
  labels      = var.labels
}

# Создание публичной подсети
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  description    = "Public subnet for VMs"
  v4_cidr_blocks = ["192.168.72.0/24"]
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  labels         = var.labels
  
  depends_on = [yandex_vpc_network.network]
}

# Создание NAT-инстанса для доступа в интернет (опционально)
resource "yandex_compute_image" "nat_instance" {
  source_family = "nat-instance-ubuntu"
}

resource "yandex_compute_instance" "nat" {
  count       = 1
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  labels      = merge(var.labels, { role = "nat" })

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.nat_instance.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true
    #ip_address = "192.168.72.1"
  }

  metadata = {
    user-data = file("${path.module}/cloud-init/nat.yaml")
  }

  scheduling_policy {
    preemptible = false
  }
}

# Настройка маршрутизации через NAT
resource "yandex_vpc_route_table" "nat_route" {
  network_id = yandex_vpc_network.network.id
  name       = "nat-route"
  labels     = var.labels

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat[0].network_interface[0].ip_address
  }
}