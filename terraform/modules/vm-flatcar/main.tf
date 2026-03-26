terraform {
  required_providers {
    ct = {
      source = "poseidon/ct"
    }
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

data "ct_config" "flatcar_ignition" {
  for_each = { for cfg in var.vm_configs : cfg.name => cfg }

  content = templatefile("${path.module}/flatcar.butane.tftpl", {
    ssh_keys = each.value.ssh_pub_keys
  })
}

resource "proxmox_virtual_environment_file" "flatcar_ignition" {
  for_each = data.ct_config.flatcar_ignition

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data      = each.value.rendered
    file_name = "flatcar-${each.key}-ignition.json"
  }
}

resource "proxmox_virtual_environment_vm" "flatcar" {
  for_each = { for cfg in var.vm_configs : cfg.name => cfg }

  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags
  node_name   = var.target_node
  vm_id       = each.value.vmid

  clone {
    vm_id = each.value.clone
  }

  cpu {
    cores = each.value.cores
    limit = each.value.cpu_limit
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_size
    aio          = "native"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.flatcar_ignition[each.key].id
  }

  dynamic "network_device" {
    for_each = each.value.networks
    iterator = net
    content {
      bridge      = net.value.bridge
      vlan_id     = net.value.vlan_id
      firewall    = net.value.firewall
      mac_address = net.value.mac
    }
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  on_boot = each.value.onboot
}
