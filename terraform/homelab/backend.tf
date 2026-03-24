terraform {
  backend "s3" {
    bucket   = "opentofu-state"
    key      = "homelab/opentofu.tfstate"
    region   = "garage"
    endpoint = var.s3_endpoint
    # access_key = "" # AWS_ACCESS_KEY_ID
    # secret_key = "" # AWS_SECRET_ACCESS_KEY

    # Required for non-AWS / self-hosted S3
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true

    # Optional but good
    encrypt      = false # Garage SSE support is limited — keep false unless tested
    use_lockfile = true  # Enables per-state locking (very useful!)
  }
}
