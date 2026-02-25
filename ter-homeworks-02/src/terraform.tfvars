vms_resources = {
  web={
    cores=2
    memory=1
    core_fraction=50
    hdd_size=5
    hdd_type="network-hdd"
  },
  db= {
    cores=2
    memory=2
    core_fraction=20
    hdd_size=5
    hdd_type="network-hdd"
  }
}

metadata = {
  web = {                        
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw3xDSnJ8UJE0+yoOirH2XfeexyepJJzSIMNMuR37z2"
  }
  db = {                         
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw3xDSnJ8UJE0+yoOirH2XfeexyepJJzSIMNMuR37z2"
  }
}