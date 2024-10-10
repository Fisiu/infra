resource "aws_s3_bucket" "s3" {
  for_each = toset(concat(var.buckets, ["opentofu"]))

  bucket        = each.value
  force_destroy = true
}
