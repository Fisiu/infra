# Garage S3 access
variable "s3_endpoint" {}
variable "s3_admin_token" {
  type      = string
  sensitive = true
}
