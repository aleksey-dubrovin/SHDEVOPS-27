# Получаем актуальный образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Первая виртуальная машина
resource "yandex_compute_instance" "app_vm_1" {
  name        = "app-vm-1"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init/docker-init.yaml", {
      mysql_host = yandex_mdb_mysql_cluster.app_mysql.host.0.fqdn
      mysql_user = yandex_mdb_mysql_user.app_user.name
      mysql_password = var.db_password
      mysql_database = yandex_mdb_mysql_database.app_db.name
    })
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  service_account_id = yandex_iam_service_account.terraform_sa.id
}

# Вторая виртуальная машина
resource "yandex_compute_instance" "app_vm_2" {
  name        = "app-vm-2"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init/docker-init.yaml", {
      mysql_host = yandex_mdb_mysql_cluster.app_mysql.host.0.fqdn
      mysql_user = yandex_mdb_mysql_user.app_user.name
      mysql_password = var.db_password
      mysql_database = yandex_mdb_mysql_database.app_db.name
    })
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  service_account_id = yandex_iam_service_account.terraform_sa.id
}