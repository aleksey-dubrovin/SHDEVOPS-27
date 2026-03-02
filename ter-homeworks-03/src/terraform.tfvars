vm_image = "fd8mor9qumsglk2a78fl"
vm_web_platform = "standard-v3"
vm_web_disk_size = 5
vm_web_disk_type = "network-hdd"
/* vms_map = {
  for vm in var.each_vm :
  vm.vm_name => vm
}
 */
each_vm = [
  {
    vm_name = "netology-develop-platform-db-main"
    cpu = 2
    ram = 2
    core_fraction = 100
    disk_volume = 10
    hdd_type = "network-hdd"
  },
  {
    vm_name = "netology-develop-platform-db-replica"
    cpu = 2
    ram = 2
    core_fraction = 50
    disk_volume = 10
    hdd_type = "network-hdd"
  }
]