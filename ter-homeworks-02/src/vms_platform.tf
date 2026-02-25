variable "vm_db_platform" {
  type = string
  description = "yandex compute instance platform"
  default = "standard-v3"
}

variable "vm_db_config" {
  description = "yandex compute instance resources"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}
