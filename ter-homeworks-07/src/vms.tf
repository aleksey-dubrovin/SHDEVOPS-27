# Данные для cloud-init
data "template_file" "cloud_init" {
  template = file("../cloud-init/docker-init.yaml")
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
      image_id = "fd80qm01ah03dqb2q6c2"  # Ubuntu 22.04 LTS
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat                = true  # Публичный IP
  }

  metadata = {
    user-data = data.template_file.cloud_init.rendered
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
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
      image_id = "fd80qm01ah03dqb2q6c2"  # Ubuntu 22.04 LTS
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat                = true  # Публичный IP
  }

  metadata = {
    user-data = data.template_file.cloud_init.rendered
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
}