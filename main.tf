module "vms" {
  source      = "./modules/vm"
  vm_configs  = var.vm_configs
  target_node = var.target_node
}

module "s3" {
  source = "./modules/nas-s3"
  buckets = var.buckets
}