variable "target_node" {
  type        = string
  description = "Target node name where configuration will be applied"
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    clone        = string
    name         = string
    desc         = optional(string, "")
    tags         = optional(string, "")
    cores        = optional(number, 1)
    memory       = optional(number, 1024)
    disk_size    = optional(string, "1G")
    agent        = optional(number, 1)
    password     = string
    ssh_pub_keys = list(string)
    packages     = optional(list(string), [])
    commands     = optional(list(string), [])
    networks = list(object({
      bridge   = optional(string, "vmbr0")
      vlan     = optional(string, "")
      firewall = optional(bool, true)
      mac      = optional(string)
    }))
  }))
}
