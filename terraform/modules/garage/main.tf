resource "garage_bucket" "this" {
  for_each = toset(concat(var.buckets, ["opentofu"]))

  global_alias = each.value
}

terraform {
  required_providers {
    garage = {
      source = "registry.terraform.io/jkossis/garage"
    }
  }
}
