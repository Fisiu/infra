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
      source  = "bpg/proxmox"
      version = "0.99.0"
    }
    telmate = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "0.16.4"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}

provider "infisical" {
  # configured with the following env variables:
  # INFISICAL_HOST
  # INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
  # INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
}

provider "proxmox" {
  endpoint  = local.pm_api_url
  api_token = local.pm_api_token
  insecure  = local.pm_tls_insecure

  ssh {
    agent    = true
    username = "root"
  }
}

provider "telmate" {
  pm_api_url          = local.pm_api_url
  pm_api_token_id     = local.pm_api_token_id
  pm_api_token_secret = local.pm_api_token_secret
  pm_tls_insecure     = local.pm_tls_insecure
}

provider "garage" {
  endpoint = var.s3_endpoint
  token    = var.s3_admin_token
}
