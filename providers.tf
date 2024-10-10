provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

provider "aws" {
  endpoints {
    s3 = var.minio_s3_endpoint
  }
  region                      = "main"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  access_key = var.minio_s3_api_key
  secret_key = var.minio_s3_secret_key
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }

  backend "s3" {
    bucket = "opentofu"
    key    = "terraform.tfstate"

    endpoints = {
      s3 = var.minio_s3_endpoint
    }
    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true

    access_key = var.minio_s3_api_key
    secret_key = var.minio_s3_secret_key
  }
}
