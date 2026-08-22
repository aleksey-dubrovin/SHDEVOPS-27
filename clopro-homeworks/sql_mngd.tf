# Добавляем три приватные подсети для MySQL
resource "yandex_vpc_subnet" "mysql_private_a" {
  name           = "mysql-private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.50.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}

resource "yandex_vpc_subnet" "mysql_private_b" {
  name           = "mysql-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.51.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}

resource "yandex_vpc_subnet" "mysql_private_c" {
  name           = "mysql-private-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.52.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}

# Кластер MySQL
resource "yandex_mdb_mysql_cluster_v2" "mysql" {
  name        = "mysql-cluster"
  description = "MySQL cluster for netology_db"
  environment = "PRESTABLE"                    # Prestable окружение
  network_id  = yandex_vpc_network.clopro.id
  version     = "8.0"

  # 3 хоста в разных зонах
  hosts = {
    host-a = {
      zone             = "ru-central1-a"
      subnet_id        = yandex_vpc_subnet.mysql_private_a.id
      assign_public_ip = false
    }
    host-b = {
      zone             = "ru-central1-b"
      subnet_id        = yandex_vpc_subnet.mysql_private_b.id
      assign_public_ip = false
    }
    host-c = {
      zone             = "ru-central1-c"
      subnet_id        = yandex_vpc_subnet.mysql_private_c.id
      assign_public_ip = false
    }
  }

  resources {
    resource_preset_id = "b1.medium"           # Intel Broadwell, 50% CPU
    disk_type_id       = "network-ssd"
    disk_size          = 20                    # 20 ГБ
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  deletion_protection = true                   # защита от удаления

  maintenance_window {
    type = "ANYTIME"                           # произвольное время
  }

  # Доступ через Web SQL (для удобства)
  access {
    web_sql = true
  }
}

# База данных
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster_v2.mysql.id
  name       = "netology_db"
}

# Пользователь
resource "yandex_mdb_mysql_user" "db_user" {
  cluster_id = yandex_mdb_mysql_cluster_v2.mysql.id
  name       = var.mysql_user                  # задать в переменных
  password   = var.mysql_password              # задать в переменных (sensitive)
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}