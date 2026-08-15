# ======================== YANDEX CLOUD ========================

variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
}

variable "yc_zone" {
  description = "Yandex Cloud availability zone"
  default     = "ru-central1-a"
}

# ======================== SSH ========================

variable "public_ssh_key_path" {
  description = "Path to public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "secure_password" {
  type    = string
  sensitive   = true  
}

# ======================== ВМ ПАРАМЕТРЫ ========================

variable "client_vm_cores" {
  description = "Number of CPU cores for client VM"
  default     = 2
}

variable "client_vm_memory" {
  description = "Memory (GB) for client VM"
  default     = 1
}

variable "client_vm_disk_size" {
  description = "Disk size (GB) for client VM"
  default     = 20
}

variable "client_vm_usage" {
  description = "Performance for a core as a percent for client VM"
  default     = 50
}

variable "nat_vm_cores" {
  description = "Number of CPU cores for NAT VM"
  default     = 2
}

variable "nat_vm_memory" {
  description = "Memory (GB) for NAT VM"
  default     = 1
}

variable "nat_vm_disk_size" {
  description = "Disk size (GB) for NAT VM"
  default     = 20
}

variable "nat_vm_usage" {
  description = "Performance for a core as a percent for NAT VM"
  default     = 50
}

variable "use_preemptible" {
  description = "Use preemptible VMs (cheaper but can be stopped)"
  default     = true
}
