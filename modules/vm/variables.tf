variable "target_node" {
  type = string
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    clone            = string
    name             = string
    cores            = optional(number, 1)
    memory           = optional(number, 1024)
    disk_size        = optional(string, "1G")
    agent            = optional(number, 1)
    network_bridge   = optional(string, "vmbr0")
    network_vlan     = optional(string, "")
    network_firewall = optional(bool, true)
    network_mac      = string
    password         = string
    ssh_pub_keys     = list(string)
  }))
}

variable "ssh_host" {
  type = string
}
variable "ssh_user" {
  type = string
}
variable "ssh_password" {
  type      = string
  sensitive = true
}
