output "vm_ips" {
  value = module.vms.vm_ips
}

output "vm_mac_addresses" {
  value = module.vms.mac_addresses
}

output "lxc_mac_addresses" {
  value = module.lxc.mac_addresses
}
