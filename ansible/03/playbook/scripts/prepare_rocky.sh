#!/bin/bash
# Подготовка Rocky Linux хостов для Ansible

# Обновление системы
sudo dnf update -y

# Установка базовых пакетов
sudo dnf install -y epel-release
sudo dnf install -y python3 python3-pip python3-libselinux \
    policycoreutils-python-utils curl wget git \
    firewalld fail2ban

# Настройка firewall
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# Настройка SELinux (менее строгий режим для тестов)
sudo setenforce 0  # Только для тестирования!
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# Настройка SSH для Ansible
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Создание пользователя для Ansible (если не существует)
if ! id rocky &>/dev/null; then
    sudo useradd -m -G wheel rocky
    echo "rocky ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/rocky
fi

# Настройка временной зоны
sudo timedatectl set-timezone Europe/Moscow

echo "Подготовка Rocky Linux завершена"