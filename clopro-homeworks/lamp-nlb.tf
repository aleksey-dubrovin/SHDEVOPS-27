# ==================== ГРУППА ДЛЯ NLB ====================
resource "yandex_compute_instance_group" "nlb_group" {
  name               = "nlb-instance-group"
  folder_id          = var.yc_folder_id
  service_account_id = var.service_account_id

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores         = var.lamp_vm_cores
      memory        = var.lamp_vm_memory
      core_fraction = var.lamp_vm_usage
    }

    scheduling_policy {
      preemptible = var.use_preemptible
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
        size     = var.lamp_vm_disk_size
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.clopro.id
      subnet_ids = [yandex_vpc_subnet.lb_private_subnet.id]
      nat        = false
      security_group_ids = [yandex_vpc_security_group.lb_sg.id]
    }

    metadata = {
      user-data = templatefile("${path.module}/cloud-init-lamp.tpl", {
        BUCKET_NAME = yandex_storage_bucket.images.bucket
        VM_PASSWORD = var.secure_password
        SSH_PUBLIC_KEY = file(var.public_ssh_key_path)
      })
    }
  }

  scale_policy {
    auto_scale {
      initial_size           = var.ig_initial_size   # 1
      max_size               = var.ig_max_size       # 3
      min_zone_size          = var.ig_min_size       # 1
      cpu_utilization_target = var.cpu_threshold     # 70%
      stabilization_duration = 60
      measurement_duration   = 60
    }
  }

  allocation_policy {
    zones = [var.yc_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 2
    max_expansion   = 2
    startup_duration = 180
  }

  # Встроенная интеграция с NLB
  load_balancer {
    target_group_name        = "nlb-target-group"
    target_group_description = "Target group for Network Load Balancer"
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name      = "external-nlb"
  folder_id = var.yc_folder_id

  listener {
    name = "http"
    port = 80
    target_port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.nlb_group.load_balancer.0.target_group_id
    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}