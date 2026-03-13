variable "yc_token" {
  description = "Yandex Cloud OAuth token"
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

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "vm_username" {
  description = "Username for VMs"
  type        = string
  default     = "rocky"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

variable "clickhouse_disk_size" {
  description = "ClickHouse VM disk size (GB)"
  type        = number
  default     = 20
}

variable "vector_disk_size" {
  description = "Vector VM disk size (GB)"
  type        = number
  default     = 10
}

variable "lighthouse_disk_size" {
  description = "Lighthouse VM disk size (GB)"
  type        = number
  default     = 10
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default = {
    environment = "production"
    managed_by  = "terraform"
    project     = "logs-platform"
  }
}

variable "service_account_id" {
  description = "Yandex Cloud Service Account ID"
  type        = string
  default     = "ajeogmb8jb2p8j0gpsia"  # ID вашего сервисного аккаунта
}

variable "use_existing_sa" {
  description = "Use existing service account instead of creating new one"
  type        = bool
  default     = true
}