# Использование существующего сервисного аккаунта
data "yandex_iam_service_account" "vm_sa" {
  service_account_id = var.service_account_id
}

# Опционально: создание статического ключа доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = data.yandex_iam_service_account.vm_sa.id
  description        = "Static access key for VM"
}

# Группы безопасности остаются без изменений
resource "yandex_vpc_security_group" "clickhouse" {
  name        = "clickhouse-sg"
  description = "Security group for ClickHouse"
  network_id  = yandex_vpc_network.network.id
  labels      = merge(var.labels, { service = "clickhouse" })

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ClickHouse HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8123
  }

  ingress {
    protocol       = "TCP"
    description    = "ClickHouse Native"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 9000
  }

  ingress {
    protocol       = "TCP"
    description    = "ClickHouse Inter-server"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 9009
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "vector" {
  name        = "vector-sg"
  description = "Security group for Vector"
  network_id  = yandex_vpc_network.network.id
  labels      = merge(var.labels, { service = "vector" })

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Vector API"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 8686
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "lighthouse" {
  name        = "lighthouse-sg"
  description = "Security group for Lighthouse"
  network_id  = yandex_vpc_network.network.id
  labels      = merge(var.labels, { service = "lighthouse" })

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}