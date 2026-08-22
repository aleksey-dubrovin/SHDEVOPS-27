# Сервисный аккаунт для доступа к Object Storage
resource "yandex_iam_service_account" "storage_sa" {
  name      = "storage-sa"
  folder_id = var.yc_folder_id
}

# Назначение роли storage.editor на каталог
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Статический ключ доступа (необходим для работы с бакетом)
resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "Static access key for storage"
}

# Бакет Object Storage
resource "yandex_storage_bucket" "images" {
  # Уникальное имя бакета (folder_id + дата)
  bucket = "images-${var.yc_folder_id}"
  folder_id = var.yc_folder_id
  default_storage_class = "INTELLIGENT_TIERING"
  max_size = 1073741824   # 1 ГБ

  # Публичный доступ на чтение
  anonymous_access_flags {
    read = true
    list = false
  }

  # Ключи доступа для управления бакетом
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  versioning {
    enabled = false
  }
}

# Загрузка файла с картинкой в бакет
resource "yandex_storage_object" "picture" {
  bucket = yandex_storage_bucket.images.bucket
  key    = "picture.jpg"
  source = var.picture_source        # локальный файл
  acl    = "public-read"             # публичный доступ к объекту

  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  depends_on = [yandex_storage_bucket.images]
}