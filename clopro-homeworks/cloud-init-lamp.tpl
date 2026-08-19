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
write_files:
  - path: "/usr/local/bin/setup-web.sh"
    permissions: "755"
    content: |
      #!/bin/bash
      set -e
      cat > /var/www/html/index.html <<EOF
      <!DOCTYPE html>
      <html>
      <head>
          <meta charset="UTF-8">
          <title>Моя страница с картинкой</title>
      </head>
      <body>
          <h1>Привет из облака!</h1>
          <img src="https://storage.yandexcloud.net/${BUCKET_NAME}/picture.jpg" alt="Картинка из бакета Object Storage" style="max-width: 100%;">
      </body>
      </html>
      EOF
      # Добавляем настройку кодировки в Apache
      echo "AddDefaultCharset UTF-8" >> /etc/apache2/apache2.conf

      systemctl restart apache2

runcmd:
  - bash /usr/local/bin/setup-web.sh 2>&1 | tee /var/log/setup-web.log