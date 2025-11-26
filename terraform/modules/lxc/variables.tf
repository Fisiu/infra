variable "target_node" {
  description = "Target node name where configuration will be applied"
  type        = string
}

variable "lxc_configs" {
  description = "List of LXC configurations"
  type = list(object({
    name            = string
    ostemplate      = optional(string, "local:vztmpl/debian-13-default_20240910_amd64.tar.xz")
    unprivileged    = optional(bool, true)
    start           = optional(bool, true)
    description     = optional(string, "")
    tags            = optional(string, "")
    onboot          = optional(bool, true)
    cores           = optional(number, 1)
    cpulimit        = optional(number, 0.0)
    cpuunits        = optional(number, 100)
    memory          = optional(number, 1024)
    swap            = optional(number, 512)
    disk_size       = optional(string, "1G")
    storage         = optional(string, "local-lvm")
    password        = string
    ssh_public_keys = optional(list(string), [])
    packages        = optional(list(string), [])
    commands        = optional(list(string), [])
    features = object({
      fuse    = optional(bool, false)
      nesting = optional(bool, false)
      mount   = optional(string, "")
    })
    nameserver = optional(string, "")
    networks = list(object({
      name     = optional(string, "eth0")
      bridge   = optional(string, "vmbr0")
      vlan     = optional(number)
      firewall = optional(bool, true)
      mac      = optional(string, "")
      ip       = optional(string, "dhcp")
      gw       = optional(string, "")
    }))
  }))
}
