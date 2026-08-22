# Сервисный аккаунт
resource "yandex_iam_service_account" "storage_sa" {
  name      = "storage-sa"
  folder_id = var.yc_folder_id
}

# Назначение роли storage.admin на папку (как в примере)
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Назначение роли для KMS (используем тот же тип ресурса)
resource "yandex_resourcemanager_folder_iam_member" "storage_sa_encrypter" {
  folder_id = var.yc_folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Ключ KMS
resource "yandex_kms_symmetric_key" "bucket_encryption_key" {
  name              = "bucket-encryption-key"
  description       = "KMS key for encrypting the Object Storage bucket"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год
}

# Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "Static access key for storage"
}

# Бакет
resource "yandex_storage_bucket" "images" {
  bucket     = "images-${var.yc_folder_id}"
  folder_id  = var.yc_folder_id
  default_storage_class = "INTELLIGENT_TIERING"
  max_size   = 1073741824

  anonymous_access_flags {
    read = true
    list = false
  }

  # Шифрование – на том же уровне, что и anonymous_access_flags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_encryption_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  versioning {
    enabled = false
  }

  depends_on = [
    yandex_kms_symmetric_key.bucket_encryption_key,
    yandex_resourcemanager_folder_iam_member.storage_sa_encrypter,
    yandex_iam_service_account_static_access_key.sa_key
  ]
}

# Объект в бакете
resource "yandex_storage_object" "picture" {
  bucket = yandex_storage_bucket.images.bucket
  key    = "picture.jpg"
  source = var.picture_source
  acl    = "public-read"

  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  depends_on = [yandex_storage_bucket.images]
}

# ==================== СТАТИЧЕСКИЙ САЙТ ====================

# Новый статический ключ для сайта (используем существующий сервисный аккаунт)
resource "yandex_iam_service_account_static_access_key" "site_sa_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "Static access key for static site bucket"
}

# Бакет для статического сайта
resource "yandex_storage_bucket" "site" {
  bucket     = var.site_name
  folder_id  = var.yc_folder_id
  acl        = "public-read"
  default_storage_class = "STANDARD"
  max_size   = 1073741824  # 1 ГБ

  access_key = yandex_iam_service_account_static_access_key.site_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.site_sa_key.secret_key

  # Хостинг будет настроен вручную, а потом импортирован
  # website {
  #   index_document = "index.html"
  #   error_document = "error.html"
  # }

  versioning {
    enabled = true
  }
}