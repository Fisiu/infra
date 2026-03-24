locals {
  # Proxmox VMs
  vm_configs = [
    {
      name      = "k3s"
      desc      = "Debian 13 k3s host</br>https://debian.org"
      vmid      = 300
      clone     = "debian"
      tags      = "homelab,k3s"
      onboot    = true
      cores     = 2
      memory    = 4096
      disk_size = "20G"
      agent     = 1
      password  = local.vm_password
      networks = [
        {
          bridge = "vmbr0"
          vlan   = "10"
          mac    = "BC:24:11:37:22:4B"
        }
      ]
      ssh_pub_keys = local.ssh_public_keys
      packages = [
        "bash-completion", "btop", "curl"
      ],
      swap_size = 536870912
    },
    {
      name      = "lfs261"
      desc      = "Ubuntu Server 24.04</br>https://ubuntu.com/server/"
      vmid      = 200
      clone     = "ubuntu"
      tags      = "network,lfs261"
      onboot    = true
      cores     = 2
      memory    = 4096
      disk_size = "20G"
      agent     = 1
      password  = local.vm_password
      networks = [
        {
          bridge = "vmbr0"
          vlan   = "10"
          mac    = "BC:24:11:37:33:4B"
        }
      ]
      ssh_pub_keys = local.ssh_public_keys
      packages = [
        "bash-completion", "btop"
      ],
      install_docker = true
    },
  ]
}
