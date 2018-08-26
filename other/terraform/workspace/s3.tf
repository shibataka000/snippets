provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/other/terraform/workspace/workspace.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_s3_bucket" "github" {
  bucket = "sbtk-terraform-workspace-sample-${terraform.workspace}"
}
