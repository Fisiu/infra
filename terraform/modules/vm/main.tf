resource "proxmox_vm_qemu" "vm" {
  for_each = { for cfg in var.vm_configs : cfg.name => cfg }

  depends_on = [
    proxmox_cloud_init_disk.ci
  ]

  target_node = var.target_node
  clone       = each.value.clone
  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags
  onboot      = each.value.onboot
  agent       = each.value.agent
  skip_ipv6   = each.value.skip_ipv6
  vmid        = coalesce(each.value.vmid, 200 + index(var.vm_configs, each.value))

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
      ide1 {
        cdrom {
          iso = proxmox_cloud_init_disk.ci[each.key].id
        }
      }
    }
  }

  dynamic "network" {
    for_each = each.value.networks

    content {
      id       = network.key
      model    = "virtio"
      bridge   = network.value.bridge
      tag      = network.value.vlan
      firewall = network.value.firewall
      macaddr  = network.value.mac
    }
  }

  serial {
    id = 0
  }

  cpu {
    sockets = 1
    cores   = each.value.cores
  }
  memory = each.value.memory
  scsihw = "virtio-scsi-single"
  boot   = "order=scsi0"

  os_type = "cloud-init"
  lifecycle {
    ignore_changes = [
      network # Prevent Terraform from detecting changes in the network configuration
    ]
  }
}

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

resource "local_file" "cloud_init_user_data_file" {
  for_each = { for cfg in var.vm_configs : cfg.name => cfg }

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
  for_each = { for cfg in var.vm_configs : cfg.name => cfg }

  name     = each.value.name
  pve_node = var.target_node
  storage  = "local"

  # user data from generated config file
  user_data = local_file.cloud_init_user_data_file[each.key].content

  meta_data = yamlencode({
    instance_id = sha1(each.value.name)
    # local-hostname = "${each.value.name}"
  })
}
