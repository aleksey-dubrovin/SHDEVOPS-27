# Получаем последний образ Container Optimized Image
data "yandex_compute_image" "cos" {
  family    = "container-optimized-image"
  folder_id = "standard-images"
}

# Шаблонизируем файл declaration.yaml с переменными
data "template_file" "declaration" {
  template = file("${path.module}/declaration.yaml")
  vars = {
    registry_id   = yandex_container_registry.app_registry.id
    app_image_tag = var.app_image_tag
    db_host       = yandex_mdb_mysql_cluster.app_mysql.host.0.fqdn
    db_user       = var.db_user
    db_password   = var.db_password
    db_name       = var.db_name
  }
}

# Шаблонизируем файл cloud_config.yaml с SSH-ключом
data "template_file" "cloud_config" {
  template = file("${path.module}/cloud_config.yaml")
  vars = {
    ssh_public_key = var.ssh_public_key
  }
}

# Основная ВМ с Container Optimized Image
resource "yandex_compute_instance" "app_vm" {
  name        = "shvirtd-app-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.cos.id
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat                = true
  }

  metadata = {
    docker-container-declaration = data.template_file.declaration.rendered
    user-data                    = data.template_file.cloud_config.rendered
  }

  service_account_id = data.yandex_iam_service_account.existing_sa.id
}