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

resource "yandex_vpc_subnet" "k8s_public_d" {
  name           = "k8s-public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.clopro.id
  v4_cidr_blocks = ["192.168.42.0/24"]
}

resource "yandex_vpc_security_group" "k8s_api_sg" {
  name        = "k8s-api-sg"
  description = "Allow kubectl access"
  network_id  = yandex_vpc_network.clopro.id

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}

# ==================== KUBERNETES CLUSTER ====================

# Сервисный аккаунт для K8s
resource "yandex_iam_service_account" "k8s_sa" {
  name      = "k8s-sa"
  folder_id = var.yc_folder_id
}

# Назначение ролей для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "k8s_clusters_agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc_public_admin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images_puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

# Кластер Kubernetes (региональный)
resource "yandex_kubernetes_cluster" "k8s" {
  name        = "k8s-cluster"
  description = "Regional Kubernetes cluster"
  network_id  = yandex_vpc_network.clopro.id

  master {
    regional {
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
        zone      = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.k8s_public_d.id
      }
    }
    public_ip = true
    security_group_ids = [yandex_vpc_security_group.k8s_api_sg.id]
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  # Шифрование секретов через KMS
  kms_provider {
    key_id = yandex_kms_symmetric_key.bucket_encryption_key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_clusters_agent,
    yandex_resourcemanager_folder_iam_member.vpc_public_admin,
    yandex_resourcemanager_folder_iam_member.images_puller
  ]
}

# ==================== NODE GROUPS ====================
# Каждая группа узлов только в одной зоне (ограничение auto_scale)

# Группа узлов в зоне ru-central1-a
resource "yandex_kubernetes_node_group" "k8s_nodes_a" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "k8s-node-group-a"
  version    = "1.35"

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
      subnet_ids = [yandex_vpc_subnet.k8s_public_a.id]
      nat        = true
    }
  }

  scale_policy {
    auto_scale {
      initial = 1
      min     = 1
      max     = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
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

# Группа узлов в зоне ru-central1-b
resource "yandex_kubernetes_node_group" "k8s_nodes_b" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "k8s-node-group-b"
  version    = "1.35"

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
      subnet_ids = [yandex_vpc_subnet.k8s_public_b.id]
      nat        = true
    }
  }

  scale_policy {
    auto_scale {
      initial = 1
      min     = 1
      max     = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
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

# Группа узлов в зоне ru-central1-d
resource "yandex_kubernetes_node_group" "k8s_nodes_d" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "k8s-node-group-d"
  version    = "1.35"

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
      subnet_ids = [yandex_vpc_subnet.k8s_public_d.id]
      nat        = true
    }
  }

  scale_policy {
    auto_scale {
      initial = 1
      min     = 1
      max     = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-d"
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