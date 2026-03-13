terraform {
  
  backend "s3" {
    
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "default"
    region                   = "ru-central1"

    bucket  = "shvirtd-tf-state-b1gr9354aii37p61ln35" # FIO-netology-tfstate
    key     = "terraform.tfstate"
    encrypt = false

    # НОВОЕ: Встроенный механизм блокировок (Terraform >= 1.6)
    # Не требует отдельной базы данных (DynamoDB/YDB)!
    use_lockfile = true

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
  }
}