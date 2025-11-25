output "mac_addresses" {
  description = "Map of LXC name -> list of MAC addresses (one entry per interface)"
  value = {
    for name, lxc in proxmox_lxc.lxc : name => [for net in lxc.network : lookup(net, "hwaddr")]
  }
}
