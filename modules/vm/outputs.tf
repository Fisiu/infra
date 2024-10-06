output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.ipconfig0]
}

output "ssh_keys" {
  value = [for k in var.vm_configs : k.ssh_pub_keys]
}

output "mac_addresses" {
  value = {
    for vm, config in proxmox_vm_qemu.vm : config.name => [
      for adapter in config.network : adapter.macaddr
    ]
  }
}
