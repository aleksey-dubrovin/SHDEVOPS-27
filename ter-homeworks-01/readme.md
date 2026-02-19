## Введение в Terraform

[Презентация]()

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
Общедоступное [зеркало](https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs) документации providers.

[Синтаксис HCL](https://developer.hashicorp.com/terraform/language/syntax/configuration)

[Resouce Blocks](https://developer.hashicorp.com/terraform/language/block/resource)

[Data Sources Blocks](https://developer.hashicorp.com/terraform/language/data-sources)

[Провайдеры](https://developer.hashicorp.com/terraform/language/block/provider)

## Домашнее задание к занятию «Введение в Terraform»
