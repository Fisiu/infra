module "s3" {
  source  = "./modules/nas-s3"
  buckets = var.s3_buckets
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
