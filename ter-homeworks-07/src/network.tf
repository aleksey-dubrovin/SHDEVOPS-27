# Используем существующую сеть
data "yandex_vpc_network" "existing_network" {
  name = "develop"  # или имя вашей сети
}

# Создаём новую подсеть 
resource "yandex_vpc_subnet" "app_subnet" {
  name           = "app-subnet"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.existing_network.id
  v4_cidr_blocks = ["192.168.172.0/24"]
}

