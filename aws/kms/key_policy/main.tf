provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/kms/key_policy"
    region = "ap-northeast-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
