# Добавляем три публичные подсети для K8s
resource "yandex_vpc_subnet" "k8s_public_a" {
  name           = "k8s-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.40.0/24"]
}

resource "yandex_vpc_subnet" "k8s_public_b" {
  name           = "k8s-public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.41.0/24"]
}

resource "yandex_vpc_subnet" "k8s_public_c" {
  name           = "k8s-public-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.42.0/24"]
}

# Сервис-аккаунт для K8s
resource "yandex_iam_service_account" "k8s_sa" {
  name      = "k8s-sa"
  folder_id = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

# Кластер Kubernetes (региональный)
resource "yandex_kubernetes_cluster" "k8s" {
  name        = "k8s-cluster"
  description = "Regional Kubernetes cluster"
  network_id  = yandex_vpc_network.clopro.id

  master {
    regional {
      # 3 master-ноды в разных зонах
      region = "ru-central1"
      location {
        zone      = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.k8s_public_a.id
      }
      location {
        zone      = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.k8s_public_b.id
      }
      location {
        zone      = "ru-central1-c"
        subnet_id = yandex_vpc_subnet.k8s_public_c.id
      }
    }
    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  # Шифрование секретов через KMS (ключ из предыдущего ДЗ)
  kms_provider {
    key_id = yandex_kms_symmetric_key.bucket_encryption_key.id
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.k8s_sa_editor]
}

# Группа узлов
resource "yandex_kubernetes_node_group" "k8s_nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "k8s-node-group"
  version    = "1.30"

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 30
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.k8s_public_a.id,
        yandex_vpc_subnet.k8s_public_b.id,
        yandex_vpc_subnet.k8s_public_c.id
      ]
      nat = true
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      min     = 3
      max     = 6
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
    location {
      zone = "ru-central1-b"
    }
    location {
      zone = "ru-central1-c"
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}