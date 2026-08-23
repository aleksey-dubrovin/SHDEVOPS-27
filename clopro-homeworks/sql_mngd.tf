# ==================== ПОДСЕТИ ДЛЯ MYSQL (PRIVATE) ====================

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

resource "yandex_vpc_subnet" "mysql_private_d" {
  name           = "mysql-private-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.52.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}

# ==================== MYSQL CLUSTER ====================

resource "yandex_mdb_mysql_cluster" "mysql" {
  name                = "mysql-cluster"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.clopro.id
  version             = "8.0"
  deletion_protection = false

  resources {
    resource_preset_id = "b2.medium"    # Intel Broadwell, 50% CPU
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  # Хосты в трёх разных зонах (a, b, d)
  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.mysql_private_a.id
    assign_public_ip = false
  }
  host {
    zone             = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.mysql_private_b.id
    assign_public_ip = false
  }
  host {
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.mysql_private_d.id
    assign_public_ip = false
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  maintenance_window {
    type = "ANYTIME"
  }

  access {
    web_sql = true
  }
}

# База данных
resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_db"
}

# Пользователь
resource "yandex_mdb_mysql_user" "db_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = var.mysql_user
  password   = var.mysql_password

  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}