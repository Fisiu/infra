terraform {
  required_version = ">= 1.0"

  required_providers {
    garage = {
      source  = "registry.terraform.io/jkossis/garage"
      version = ">= 1.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }

  # TODO: It sems backend is not working with garage s3
  # backend "s3" {
  #   bucket = "opentofu"
  #   key    = "terraform.tfstate"

  #   endpoints = {
  #     s3 = var.s3_endpoint
  #   }
  #   region                      = var.s3_region
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  #   use_path_style              = true
  # }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

provider "garage" {
  endpoint = var.s3_endpoint
  token    = var.s3_admin_token
}
