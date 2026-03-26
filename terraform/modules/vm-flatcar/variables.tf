variable "target_node" {
  type        = string
  description = "The target node to deploy the VM on"
}

variable "vm_configs" {
  description = "VM configuration objects to deploy"
  type = list(object({
    name         = string
    vmid         = number
    clone        = optional(string, "flatcar")
    description  = optional(string, "Flatcar Container Linux</br>https://flatcar.org")
    tags         = optional(list(string), [])
    onboot       = optional(bool, true)
    cores        = optional(number, 2)
    cpu_limit    = optional(number)
    memory       = optional(number, 4096)
    disk_size    = optional(number, 20)
    ssh_pub_keys = list(string)
    networks = list(object({
      bridge   = optional(string, "vmbr0")
      vlan_id  = optional(number)
      firewall = optional(bool, true)
      mac      = optional(string)
    }))
  }))
}
