## Продвинутые методы работы с Terraform

* Научиться переиспользовать Terraform-код
* Детально изучить всё, что связано с Terraform state

[Разбор использованного модуля, переменных (обязательные и опциональные)](https://github.com/udjin10/yandex_compute_instance?ref=main)

[Terraform-switcher](https://tfswitch.warrensbox.com/)

[Terraform-docs](https://terraform-docs.io/)

```bash
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u)\
quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs
```

### Cloud-init

Пример cloud-init.yml
```yaml
users:
- name: ubuntu
groups: sudo
shell: /bin/bash
sudo: ['ALL=(ALL) NOPASSWD:ALL']
ssh-authorized-keys:
- ssh-ed25519 AAAAB............
- ssh-ed25519 AAAAC............
package_update: true
packages_upgrade: true
packages:
- vim
runcmd:
- ufw allow 22
- echo "y" | ufw enable
```

Пример передачи cloud-config в ВМ
```hcl
data "template_file" "cloudinit" {
template = file("./cloud-init.yml")
}
resource "yandex_compute_instance" "vm" {
metadata={
user-data=data.template_file.cloudinit
}}
```

[Хранение секретов в HashiCorp Vault](https://hub.docker.com/_/vault)

[Documentation Vault](https://developer.hashicorp.com/vault/docs/concepts/dev-server)

[Terraform Vault Provider](https://registry.tfpla.net/providers/hashicorp/vault/latest/docs)

Пример считывания секрета из Vault
```hcl
data "vault_kv_secret_v2" "tls_example_ru" {
mount = "tls_certs"
name = "wildcard.example.ru"
}
```

* [Документация модулей](https://developer.hashicorp.com/terraform/language/modules)

* [Документация state](https://developer.hashicorp.com/terraform/language/state)

