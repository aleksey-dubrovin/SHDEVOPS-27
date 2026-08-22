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

variable "service_account_id" {
  description = "ID of existing service account for Instance Group"
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
  default     = 15
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
  default     = 10
}

variable "nat_vm_usage" {
  description = "Performance for a core as a percent for NAT VM"
  default     = 50
}

variable "use_preemptible" {
  description = "Use preemptible VMs (cheaper but can be stopped)"
  default     = true
}

# ==================== INSTANCE GROUP (ДЗ2) ====================

variable "lamp_vm_cores" {
  description = "Number of CPU cores for NAT VM"
  default     = 2
}

variable "lamp_vm_memory" {
  description = "Memory (GB) for NAT VM"
  default     = 2
}

variable "lamp_vm_disk_size" {
  description = "Disk size (GB) for NAT VM"
  default     = 15
}

variable "lamp_vm_usage" {
  description = "Performance for a core as a percent for NAT VM"
  default     = 100
}

variable "ig_initial_size" {
  description = "Initial number of instances in the group"
  default     = 1
}

variable "ig_min_size" {
  description = "Minimum number of instances (for auto-scaling)"
  default     = 1
}

variable "ig_max_size" {
  description = "Maximum number of instances (for auto-scaling)"
  default     = 3
}

variable "cpu_threshold" {
  description = "CPU utilization threshold (%) for auto-scaling"
  default     = 70
}

variable "lamp_image_id" {
  description = "Image ID for LAMP stack (from Yandex Cloud Marketplace)"
  default     = "fd827b91d99psvq5fjit"
}

# ==================== STORAGE (Object Storage) ====================
variable "picture_source" {
  description = "Local path to the image file to upload to bucket"
  default     = "./picture.jpg"
}

# ==================== INTERNAL BALANCER IPs (for DNAT on NAT) ====================
variable "alb_internal_ip" {
  description = "Internal IP address for Application Load Balancer"
  default     = "192.168.10.11"
}