# Получение последнего образа Rocky Linux с OS Login
data "yandex_compute_image" "rocky_linux" {
  family = "rocky-9-oslogin"
}

# Чтение SSH ключа
data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

# Шаблоны cloud-init
data "template_file" "clickhouse_cloudinit" {
  template = file("${path.module}/cloud-init/clickhouse.yaml")
  vars = {
    ssh_public_key = chomp(data.local_file.ssh_public_key.content)
  }
}

data "template_file" "vector_cloudinit" {
  template = file("${path.module}/cloud-init/vector.yaml")
  vars = {
    ssh_public_key = chomp(data.local_file.ssh_public_key.content)
  }
}

data "template_file" "lighthouse_cloudinit" {
  template = file("${path.module}/cloud-init/lighthouse.yaml")
  vars = {
    ssh_public_key = chomp(data.local_file.ssh_public_key.content)
  }
}

# ClickHouse VM
resource "yandex_compute_instance" "clickhouse" {
  name        = "clickhouse-01"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  description = "ClickHouse database server"
  folder_id   = var.yc_folder_id
  labels      = merge(var.labels, { 
    role = "clickhouse",
    group = "clickhouse"
  })

allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.rocky_linux.id
      size     = var.clickhouse_disk_size
      type     = "network-ssd"
      name     = "clickhouse-boot-disk"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.clickhouse.id]
  }

  metadata = {
    user-data = data.template_file.clickhouse_cloudinit.rendered
    ssh-keys  = "rocky:${chomp(data.local_file.ssh_public_key.content)}"
  }

  scheduling_policy {
    preemptible = false
  }

  service_account_id = var.service_account_id  # Используем существующий SA
}

# Vector VM
resource "yandex_compute_instance" "vector" {
  name        = "vector-01"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  description = "Vector log aggregator"
  folder_id   = var.yc_folder_id
  labels      = merge(var.labels, { 
    role = "vector",
    group = "vector"
  })

allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.rocky_linux.id
      size     = var.vector_disk_size
      type     = "network-ssd"
      name     = "vector-boot-disk"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vector.id]
  }

  metadata = {
    user-data = data.template_file.vector_cloudinit.rendered
    ssh-keys  = "rocky:${chomp(data.local_file.ssh_public_key.content)}"
  }

  scheduling_policy {
    preemptible = false
  }

  service_account_id = var.service_account_id  # Используем существующий SA
}

# Lighthouse VM
resource "yandex_compute_instance" "lighthouse" {
  name        = "lighthouse-01"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  description = "Lighthouse web interface"
  folder_id   = var.yc_folder_id
  labels      = merge(var.labels, { 
    role = "lighthouse",
    group = "lighthouse"
  })

allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.rocky_linux.id
      size     = var.lighthouse_disk_size
      type     = "network-ssd"
      name     = "lighthouse-boot-disk"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.lighthouse.id]
  }

  metadata = {
    user-data = data.template_file.lighthouse_cloudinit.rendered
    ssh-keys  = "rocky:${chomp(data.local_file.ssh_public_key.content)}"
  }

  scheduling_policy {
    preemptible = false
  }

  service_account_id = var.service_account_id  # Используем существующий SA
}

# Генерация Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    clickhouse_ip = yandex_compute_instance.clickhouse.network_interface.0.nat_ip_address
    vector_ip     = yandex_compute_instance.vector.network_interface.0.nat_ip_address
    lighthouse_ip = yandex_compute_instance.lighthouse.network_interface.0.nat_ip_address
    ssh_user      = var.vm_username
    ssh_key_path  = var.ssh_private_key_path
  })
  filename = "${path.module}/../playbook/inventory/prod.yml"
}