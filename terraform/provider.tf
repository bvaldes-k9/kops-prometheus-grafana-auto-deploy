provider "aws" {
  region = "your_region"
  profile = "iam_user"
}

data "aws_availability_zones" "available" {}