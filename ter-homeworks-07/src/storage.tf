resource "yandex_storage_bucket" "tf_state_bucket" {
  bucket = "shvirtd-tf-state-${var.yc_folder_id}"
  access_key = var.s3_access_key
  secret_key = var.s3_secret_key
  max_size = 1073741824
  versioning {
    enabled = true
  }
  tags = {
    Name = "Terraform State"
  }
}
