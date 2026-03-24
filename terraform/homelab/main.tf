module "garage" {
  source  = "../modules/garage"
  buckets = local.garage_buckets
}

module "vms" {
  source      = "../modules/vm"
  target_node = local.target_node
  vm_configs  = local.vm_configs
}

module "lxc" {
  source      = "../modules/lxc"
  target_node = local.target_node
  lxc_configs = local.lxc_configs
}
