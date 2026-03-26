locals {
  vm_flatcar_configs = [
    {
      name = "flatcar"
      # desc      = "Debian 13 k3s host</br>https://debian.org"
      vmid      = 500
      clone     = 5000
      tags      = ["homelab", "flatcar"]
      onboot    = true
      cores     = 2
      memory    = 4096
      disk_size = 20
      password  = local.vm_password
      networks = [
        {
          bridge  = "vmbr0"
          vlan_id = 10
          mac     = "BC:24:11:39:11:AA"
        }
      ]
      ssh_pub_keys = local.ssh_public_keys
    },
  ]
}
