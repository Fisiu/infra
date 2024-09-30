output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.ipconfig0]
}

output "ssh_keys" {
  value = [for k in var.vm_configs : k.ssh_pub_keys]
}
