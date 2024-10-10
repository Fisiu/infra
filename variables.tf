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

# Proxmox VM configs
variable "target_node" {
  type = string
}
variable "vm_configs" {
  description = "List of VM configurations"
}

# Minio S3 access
variable "minio_s3_endpoint" {}
variable "minio_s3_api_key" {
  sensitive = true
}
variable "minio_s3_secret_key" {
  sensitive = true
}

# Minio S3
variable "buckets" {
  description = "List of S3 buckets"
}
