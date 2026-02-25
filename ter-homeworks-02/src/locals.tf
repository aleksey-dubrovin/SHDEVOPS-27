locals {
  vm_web_name = "netology-${var.vpc_name}-platform-${var.vm_purpose[0]}"
  vm_db_name = "netology-${var.vpc_name}-platform-${var.vm_purpose[1]}"
}