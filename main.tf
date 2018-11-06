terraform {
  backend "s3" {
    bucket  = "terraform-state-291104527402"
    key     = "code-pipeline-infrastructure.tfstate"
    region  = "ap-southeast-2"
    profile = "default"
  }
}

data "aws_caller_identity" "default" {}

data "aws_region" "default" {}
