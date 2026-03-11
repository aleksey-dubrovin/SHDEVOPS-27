# Создание Managed MySQL кластера
resource "yandex_mdb_mysql_cluster" "app_mysql" {
  name                = "app-mysql"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.app_network.id
  version             = "8.0"
  security_group_ids  = [yandex_vpc_security_group.mysql_sg.id]

  resources {
    resource_preset_id = "b2.nano"  # 2 CPU, 2 RAM
    disk_type_id       = "network-ssd"
    disk_size          = 10          # 10 GB
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