# Создание Managed MySQL кластера
resource "yandex_mdb_mysql_cluster" "app_mysql" {
  name                = "app-mysql"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.app_network.id
  version             = "8.0"
  security_group_ids  = [yandex_vpc_security_group.mysql_sg.id]

  resources {
    resource_preset_id = "s2.micro"  # 2 vCPU, 8 GB RAM
    disk_type_id       = "network-ssd"
    disk_size          = 10
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.app_subnet.id
    assign_public_ip = false
  }
}

# База данных
resource "yandex_mdb_mysql_database" "app_db" {
  cluster_id = yandex_mdb_mysql_cluster.app_mysql.id
  name       = "app_db"
}

# Пользователь базы данных
resource "yandex_mdb_mysql_user" "app_user" {
  cluster_id = yandex_mdb_mysql_cluster.app_mysql.id
  name       = "app_user"
  password   = var.db_password
  
  permission {
    database_name = yandex_mdb_mysql_database.app_db.name
    roles         = ["ALL"]
  }
}