resource "aws_s3_bucket" "kops_state" {
  bucket = "clusters-yoursubdomain-domain-com"
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }
}