# Proxmox VM/LXC configs
variable "target_node" {
  type = string
}
variable "vm_configs" {
  description = "List of VM configurations"
}
variable "lxc_configs" {
  description = "List of LXC configurations"
}

# Garage S3 access
variable "s3_endpoint" {}
variable "s3_admin_token" {
  type      = string
  sensitive = true
}

# Garage
variable "garage_buckets" {
  description = "List of garage buckets"
}
