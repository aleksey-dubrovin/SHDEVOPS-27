terraform {
  required_version = ">=1.5"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
  # service_account_key_file = file("~/yandex-cloud/.authorized_key.json")
}