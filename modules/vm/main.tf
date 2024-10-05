resource "proxmox_vm_qemu" "vm" {
  for_each = { for id, config in var.vm_configs : id => config }

  depends_on = [
    proxmox_cloud_init_disk.ci
  ]

  target_node = var.target_node
  clone       = each.value.clone
  name        = each.value.name
  agent       = each.value.agent

  disks {
    scsi {
      scsi0 {
        disk {
          size     = each.value.disk_size
          storage  = "local-lvm"
          asyncio  = "native"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = proxmox_cloud_init_disk.ci[each.key].id
        }
      }
    }
  }

  network {
    model    = "virtio"
    bridge   = each.value.network_bridge
    tag      = each.value.network_vlan
    firewall = each.value.network_firewall
    macaddr  = each.value.network_mac
  }

  serial {
    id = 0
  }

  vga {
    type = "serial0"
  }

  sockets = 1
  cores   = each.value.cores
  memory  = each.value.memory
  scsihw  = "virtio-scsi-single"
  boot    = "order=scsi0"

  os_type = "cloud-init"
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

resource "local_file" "cloud_init_user_data_file" {
  for_each = { for id, config in var.vm_configs : id => config }

  content = templatefile("${path.module}/userdata.tftpl", {
    hostname = each.value.name
    password = each.value.password
    ssh_keys = each.value.ssh_pub_keys
    packages = each.value.packages
    commands = each.value.commands
  })
  filename = "${path.module}/cloud-init/${each.value.name}-user-data"
}

resource "proxmox_cloud_init_disk" "ci" {
  for_each = { for id, config in var.vm_configs : id => config }

  name     = each.value.name
  pve_node = var.target_node
  storage  = "local"

  # user data from generated config file
  user_data = local_file.cloud_init_user_data_file[each.key].content

  # dhcp on eth0 works for me
  network_config = yamlencode({
    version = 2
    ethernets = [
      {
        eth0 = [
          {
            dhcp4 = true
          }
        ]
      }
    ]
  })

  meta_data = yamlencode({
    instance_id    = sha1(each.value.name)
    local-hostname = "${each.value.name}"
  })
}
