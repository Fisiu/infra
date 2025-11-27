resource "proxmox_lxc" "lxc" {
  for_each = { for cfg in var.lxc_configs : cfg.name => cfg }

  target_node  = var.target_node
  hostname     = each.value.name
  ostemplate   = each.value.ostemplate
  unprivileged = each.value.unprivileged
  start        = each.value.start

  description = each.value.description
  tags        = each.value.tags
  onboot      = each.value.onboot

  # Terraform will crash without rootfs defined
  rootfs {
    storage = each.value.storage
    size    = each.value.disk_size
  }

  features {
    fuse    = each.value.features.fuse
    nesting = each.value.features.nesting
    mount   = each.value.features.mount
  }

  dynamic "network" {
    for_each = each.value.networks

    content {
      name     = network.value.name
      bridge   = network.value.bridge
      tag      = network.value.vlan
      firewall = network.value.firewall
      hwaddr   = network.value.mac
      ip       = network.value.ip
      # Only set if a static IP is configured (not dhcp/manual) AND gateway is provided.
      gw = (length(network.value.ip) > 0 && network.value.ip != "dhcp" && network.value.ip != "manual" && length(network.value.gw) > 0) ? network.value.gw : null
    }
  }

  nameserver = each.value.nameserver

  cores    = each.value.cores
  cpulimit = each.value.cpulimit
  cpuunits = each.value.cpuunits
  memory   = each.value.memory
  swap     = each.value.swap

  password        = each.value.password
  ssh_public_keys = join("\n", each.value.ssh_public_keys)

  # giving some time to the container to start
  provisioner "local-exec" {
    command = "logger 'This container was built on $(date)'"
  }

  lifecycle {
    ignore_changes = [
      network,    # Prevent Terraform from detecting changes in the network configuration
      description # Prevent Terraform from detecting changes in the description
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
