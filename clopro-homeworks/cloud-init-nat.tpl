#cloud-config
ssh_pwauth: no
users:
  - name: ubuntu
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY}
chpasswd:
  list: |
    ubuntu:${VM_PASSWORD}
  expire: false

package_update: true
packages:
  - nftables

write_files:
  - path: /etc/nftables.conf
    owner: root:root
    permissions: '0644'
    content: |
      #!/usr/sbin/nft -f
      flush ruleset

      table ip nat {
        chain prerouting {
          type nat hook prerouting priority filter; policy accept;
            # Автоматический проброс портов на внутренние порты
            tcp dport 2222 dnat ip to 192.168.20.10:22
            tcp dport 80 dnat ip to 192.168.10.11:80
        }
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          # Маскарадинг для всей внутренней подсети
            oif "eth0" masquerade
        }
      }
      # Таблица filter для контроля доступа
      table inet filter {
      # Цепочка для входящего трафика на сам шлюз
        chain input {
          type filter hook input priority filter; policy drop;
            # Разрешить loopback
            iif lo accept
            # Разрешить established и related соединения
            ct state established,related accept
            # Разрешить SSH для управления шлюзом (опционально)
            tcp dport 22 ct state new accept
            # Разрешить ICMP (ping)
            ip protocol icmp accept
      }
      # Цепочка для транзитного трафика
        chain forward {
          type filter hook forward priority filter; policy accept;
            # Разрешить established и related
            ct state established,related accept
            # Разрешить новые соединения к проброшенным сервисам
            ct state new tcp dport 22 accept
      }
      # Цепочка для исходящего трафика
        chain output {
          type filter hook output priority filter; policy accept;
        }
      }
          
runcmd:
  - sysctl --system
  - systemctl enable nftables
  - systemctl restart nftables