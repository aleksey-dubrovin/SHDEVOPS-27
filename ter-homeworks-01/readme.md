## Домашнее задание к занятию «Введение в Terraform»

Подробная [инструкция](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider) от Yandex Сloud
```
provider_installation {
network_mirror {
url = "https://terraform-mirror.yandexcloud.net/"
include = ["registry.terraform.io/*/*"]
}
direct {
exclude = ["registry.terraform.io/*/*"]
}
}
```
