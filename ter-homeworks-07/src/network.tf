# Создание VPC
resource "yandex_vpc_network" "app_network" {
  name = "app-network"
}

# Создание подсети в зоне ru-central1-a
resource "yandex_vpc_subnet" "app_subnet" {
  name           = "app-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["192.168.72.0/24"]
}