resource "aws_s3_bucket" "s3" {
  for_each = toset(var.buckets)

  bucket = each.value
  force_destroy = true  
}
