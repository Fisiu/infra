module "garage" {
  source  = "./modules/garage"
  buckets = var.garage_buckets
}

module "vms" {
  source      = "./modules/vm"
  vm_configs  = var.vm_configs
  target_node = var.target_node
}

module "lxc" {
  source      = "./modules/lxc"
  target_node = var.target_node
  lxc_configs = var.lxc_configs
}
