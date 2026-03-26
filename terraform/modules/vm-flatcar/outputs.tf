output "vm_ids" {
  description = "Map of VM names to their IDs"
  value = {
    for k, v in proxmox_virtual_environment_vm.flatcar : k => v.id
  }
}

output "vm_ips" {
  description = "Map of VM names to their IPv4 addresses"
  value = {
    for k, v in proxmox_virtual_environment_vm.flatcar : k => v.ipv4_addresses
  }
}
