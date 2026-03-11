/* terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-state-bucket"  # Создайте bucket в Yandex Cloud заранее
    region     = "ru-central1"
    key        = "shvirtd/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
} */