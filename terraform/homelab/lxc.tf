locals {
  # Proxmox LXC
  lxc_configs = [
    {
      name        = "prometheus"
      ostemplate  = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
      description = "Prometheus"
      tags        = "monitoring"
      cores       = 1
      memory      = 2048
      disk_size   = "4G"
      password    = local.lxc_password
      onboot      = true
      features = {
        nesting = true # Enable nesting for Prometheus container, required!!!
      }
      networks = [
        {
          name   = "eth0",
          bridge = "vmbr0",
          vlan   = 10
        }
      ]
      ssh_public_keys = local.ssh_public_keys
    },
    {
      name        = "grafana"
      ostemplate  = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
      description = "Grafana"
      tags        = "monitoring"
      cores       = 1
      memory      = 1024
      disk_size   = "3G"
      password    = local.lxc_password
      onboot      = true
      features = {
        nesting = true
      }
      networks = [
        {
          name   = "eth0",
          bridge = "vmbr0",
          vlan   = 10
        }
      ]
      ssh_public_keys = local.ssh_public_keys
    },
    {
      name        = "pve-exporter"
      ostemplate  = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
      description = "Prometheus Proxmox Exporter"
      tags        = "monitoring"
      cores       = 1
      memory      = 512
      swap        = 128
      disk_size   = "2G"
      password    = local.lxc_password
      onboot      = true
      features = {
        nesting = true
      }
      networks = [
        {
          name   = "eth0",
          bridge = "vmbr0",
          vlan   = 10
        }
      ]
      ssh_public_keys = local.ssh_public_keys
    },
    {
      name        = "jenkins"
      ostemplate  = "local:vztmpl/debian-12-turnkey-jenkins_18.1-1_amd64.tar.gz"
      description = "Jenkins"
      tags        = "devops"
      cores       = 1
      memory      = 2048
      disk_size   = "20G"
      password    = local.lxc_password
      onboot      = true
      features = {
        nesting = true
      }
      networks = [
        {
          name   = "eth0",
          bridge = "vmbr0",
          vlan   = 10,
          mac    = "BC:24:11:D8:3E:EA"
        }
      ]
      ssh_public_keys = local.ssh_public_keys
    },
  ]
}
