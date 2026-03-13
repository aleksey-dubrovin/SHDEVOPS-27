# Группа безопасности для ВМ
resource "yandex_vpc_security_group" "vm_sg" {
  name        = "vm-security-group"
  network_id  = data.yandex_vpc_network.existing_network.id  # или yandex_vpc_network.app_network.id

  # SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (порт 80) - для внешнего доступа
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Порт приложения 5000
  ingress {
    protocol       = "TCP"
    port           = 5000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик разрешен весь
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
# Группа безопасности для MySQL (доступ только из ВМ)
resource "yandex_vpc_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Security group for Managed MySQL"
  network_id  = data.yandex_vpc_network.existing_network.id  # или yandex_vpc_network.app_network.id

  # Разрешаем входящий трафик на порт 3306 только из группы безопасности ВМ
  ingress {
    protocol          = "TCP"
    port              = 3306
    security_group_id = yandex_vpc_security_group.vm_sg.id  # ссылка на группу ВМ
    description       = "MySQL access from app VMs"
  }

  # Исходящий трафик разрешен весь
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outbound traffic"
  }
}