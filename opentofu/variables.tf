# Proxmox access
variable "pm_api_url" {
  type = string
}
variable "pm_api_token_id" {
  type      = string
  sensitive = true
}
variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}
variable "pm_tls_insecure" {
  type    = bool
  default = true
}

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
  sensitive = true
}

# S3
variable "s3_buckets" {
  description = "List of S3 buckets"
}
