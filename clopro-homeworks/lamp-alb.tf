# Бэкенд-группа
resource "yandex_alb_backend_group" "alb_backend" {
  name      = "alb-backend"
  folder_id = var.yc_folder_id

  http_backend {
    name = "alb-http-backend"
    port = 80
    target_group_ids = [yandex_compute_instance_group.alb_group.application_load_balancer.0.target_group_id]

    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout  = "1s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# Внутренний ALB
resource "yandex_alb_load_balancer" "alb" {
  name        = "internal-alb"
  network_id  = yandex_vpc_network.clopro.id
  folder_id   = var.yc_folder_id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.public_subnet.id
    }
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        internal_ipv4_address {
          subnet_id = yandex_vpc_subnet.public_subnet.id
          address   = var.alb_internal_ip
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb_router.id
      }
    }
  }
}

# ==================== ГРУППА ДЛЯ ALB ====================
resource "yandex_compute_instance_group" "alb_group" {
  name               = "alb-instance-group"
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
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
        size     = var.lamp_vm_disk_size
        type     = "network-hdd"
      }
    }

    network_interface {
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
      initial_size           = var.ig_initial_size
      max_size               = var.ig_max_size
      min_zone_size          = var.ig_min_size
      cpu_utilization_target = var.cpu_threshold
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

  # Встроенная интеграция с ALB
  application_load_balancer {
    target_group_name        = "alb-target-group"
    target_group_description = "Target group for Application Load Balancer"
  }
}

# ==================== APPLICATION LOAD BALANCER (внутренний) ====================
# HTTP-роутер
resource "yandex_alb_http_router" "alb_router" {
  name      = "internal-alb-router"
  folder_id = var.yc_folder_id
}

# Виртуальный хост
resource "yandex_alb_virtual_host" "alb_host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb_router.id

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb_backend.id
        timeout          = "10s"
      }
    }
  }
}