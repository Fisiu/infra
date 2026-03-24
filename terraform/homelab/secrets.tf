variable "infisical_environment" {
  description = "The environment from infisical [dev, staging, prod]"
  type        = string
  default     = "prod"
}

variable "infisical_workspace_id" {
  description = "Infisical project/workspace ID"
  type        = string
  sensitive   = true
}

variable "infisical_infrastructure_path" {
  description = "Infisical infrastructure path"
  type        = string
  default     = "/infrastructure"
}

data "infisical_secrets" "infrastructure" {
  env_slug     = var.infisical_environment
  folder_path  = var.infisical_infrastructure_path
  workspace_id = var.infisical_workspace_id
}

locals {
  pm_api_host         = data.infisical_secrets.infrastructure.secrets["PM_API_HOST"].value
  pm_api_url          = data.infisical_secrets.infrastructure.secrets["PM_API_URL"].value
  pm_api_token_id     = sensitive(data.infisical_secrets.infrastructure.secrets["PM_API_TOKEN_ID"].value)
  pm_api_token_secret = sensitive(data.infisical_secrets.infrastructure.secrets["PM_API_TOKEN_SECRET"].value)
  pm_tls_insecure     = try(tobool(data.infisical_secrets.infrastructure.secrets["PM_TLS_INSECURE"].value), true)
}

locals {
  vm_username  = data.infisical_secrets.infrastructure.secrets["VM_USERNAME"].value
  vm_password  = sensitive(data.infisical_secrets.infrastructure.secrets["VM_PASSWORD"].value)
  lxc_password = sensitive(data.infisical_secrets.infrastructure.secrets["LXC_PASSWORD"].value)
}

locals {
  ssh_public_keys = nonsensitive(tolist(split("\n", trimspace(data.infisical_secrets.infrastructure.secrets["SSH_PUBLIC_KEYS"].value))))
}
