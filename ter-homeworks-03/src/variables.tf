###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vm_image" {
  type = string
  description = "идентификатор образа для ВМ"
}
variable "vm_web_platform" {
  type = string
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}
variable "vm_storage_platform" {
  type = string
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}
variable "vm_web_disk_size" {
  type = number
  description = "размер диска в ГБ"
}
variable "vm_web_disk_type" {
  type = string
  description = "тип создаваемого диска"
}
variable "vm_storage_disk_type" {
  type = string
  description = "тип создаваемого диска"
}
variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
    core_fraction = number
    hdd_type = string
  }))
}
variable "metadata_map" {
type = map(object({
serial-port-enable = number
ssh-keys = string
}))
sensitive = true
}