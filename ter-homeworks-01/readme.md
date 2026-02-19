## Введение в Terraform

[Презентация](https://github.com/aleksey-dubrovin/SHDEVOPS-27/blob/main/ter-homeworks-01/1._Введение_в_Terraform.pdf)

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

#### 1.

<img width="1145" height="1016" alt="image" src="https://github.com/user-attachments/assets/b7cd89dd-a8dd-45eb-b8fc-d6bb2e8733b9" />

#### 2.

```
# Local .terraform directories and files
**/.terraform/*
.terraform*

!.terraformrc

# .tfstate files
*.tfstate
*.tfstate.*

# own secret vars store.
personal.auto.tfvars
```
Файл .gitignore исключает из публикации все файлы ,названия которых начинаются с .terraform и каталог .terraform. Так же исключает файлы текущего состояния развернутой системы *.tfstate и файл именнования personal.auto.tfvars. Соотвественно в данных файлах можно безопасно хранить личную и секретную информацию. 
А вот файл terraform.tfvars не указан в исключении ,поэтому хранить в нём секретные перемененые не рекомендуется.

#### 3.

<img width="1405" height="909" alt="image" src="https://github.com/user-attachments/assets/510ad0c8-23ee-4578-ac99-409d80349747" />

>[!CAUTION]
>"result": "JZO4AanA3XhcZEDs",

<img width="1421" height="1226" alt="image" src="https://github.com/user-attachments/assets/3f10825b-89d6-4b1d-8515-09db5d9ba9a6" />

#### 4.

<img width="1173" height="443" alt="image" src="https://github.com/user-attachments/assets/61f711e3-0f57-4b07-98f3-ba1b6c4fe227" />

- Добавлен label для *resource "docker_image" "nginx_latest"*
- Исправлен label для *resource "docker_container" "nginx-1"*
- Исправлена ссылка на образ из ресурса *image = docker_image.nginx_latest.image_id*
- Исправлено значение переменной для имени контейнера *"example_${random_password.random_string.result}"*

#### 5.

<img width="1447" height="1215" alt="image" src="https://github.com/user-attachments/assets/ae6807e2-f287-40ff-99fe-1baf6f28b54c" />

#### 6.

<img width="1300" height="1157" alt="image" src="https://github.com/user-attachments/assets/69e4bac8-4374-40bd-9377-24bea9779dec" />

При применении конфигурации с ключом -auto-approve ,существует риск непрнамеренного удаления или изменения ресурсов. Данный ключ полезен в тестовых средах или для автоматизации через git когда нет возможности явно ввести yes при применний конфигурации.

#### 7.

```
{
  "version": 4,
  "terraform_version": "1.14.5",
  "serial": 14,
  "lineage": "f1b87b53-e40c-6a4c-05bf-c46a7e5032fe",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

#### 8.

```
# docker_image.nginx_latest will be destroyed
  - resource "docker_image" "nginx_latest" {
      - id           = "sha256:5cdef4ac3335f68428701c14c5f12992f5e3669ce8ab7309257d263eb7a856b1nginx:latest" -> null
      - image_id     = "sha256:5cdef4ac3335f68428701c14c5f12992f5e3669ce8ab7309257d263eb7a856b1" -> null
      - keep_locally = true -> null
      - name         = "nginx:latest" -> null
      - repo_digest  = "nginx@sha256:341bf0f3ce6c5277d6002cf6e1fb0319fa4252add24ab6a0e262e0056d313208" -> null
    }
```
Для создания ресурса nginx_latest используется базовый образ из репозитория с параметром *keep_locally = true*.
**keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation.**





