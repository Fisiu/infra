variable "target_node" {
  type        = string
  description = "Target node name where configuration will be applied"
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    clone        = string
    name         = string
    description  = optional(string, "")
    tags         = optional(string, "")
    onboot       = optional(bool, true)
    cores        = optional(number, 1)
    memory       = optional(number, 1024)
    disk_size    = optional(string, "1G")
    agent        = optional(number, 1)
    skip_ipv6    = optional(bool, true)
    password     = string
    ssh_pub_keys = list(string)
    packages     = optional(list(string), [])
    commands     = optional(list(string), [])
    vmid         = optional(number)
    networks = list(object({
      bridge   = optional(string, "vmbr0")
      vlan     = optional(string, "")
      firewall = optional(bool, true)
      mac      = optional(string)
    }))
  }))

  validation {
    condition     = length(distinct([for v in var.vm_configs : v.name])) == length(var.vm_configs)
    error_message = "Each element in var.vm_configs must have a unique 'name' field."
  }
}
