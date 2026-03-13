variable "yc_token" {
  description = "Yandex Cloud OAuth token or IAM token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for VMs"
  type        = string
}

variable "db_password" {
  description = "Password for MySQL database"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username for MySQL database"
  type        = string
  default     = "app_user"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "app_db"
}

variable "app_image_tag" {
  description = "Tag for the application Docker image"
  type        = string
  default     = "latest"
}

variable "service_account_name" {
  description = "Name of existing service account to use"
  type        = string
  default     = "default"
}

variable "service_account_id" {
  description = "ID of existing service account (if known)"
  type        = string
  default     = ""
}
variable "s3_access_key"{
  description = "yandex_iam_service_account_static_access_key.sa-static-key.access_key"
  type = string  
}
variable "s3_secret_key"{
  description = "yandex_iam_service_account_static_access_key.sa-static-key.secret_key"
  type = string
}