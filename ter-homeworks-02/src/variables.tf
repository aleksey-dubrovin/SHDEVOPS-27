###cloud vars


variable "cloud_id" {
  type        = string
  default = "b1g5akar41n0hohkvoq7"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default = "b1glfq89j9n7quk0cnf0"
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
  description = "VPC network & subnet name"
}

variable "vm_web_image" {
  type = string
  description = "yandex compute image"
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type = string
  description = "yandex compute instance name"
  default = "netology-develop-platform-web"
}

variable "vm_web_platform" {
  type = string
  description = "yandex compute instance platform"
  default = "standard-v3"
}

variable "vm_web_config" {
  description = "yandex compute instance resources"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 50
  }
}

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw3xDSnJ8UJE0+yoOirH2XfeexyepJJzSIMNMuR37z2 aleksey.vladch@yandex.ru"
  description = "ssh-keygen -t ed25519"
}