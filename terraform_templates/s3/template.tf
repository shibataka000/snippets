variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# S3
resource "aws_s3_bucket" "bucket" {
  bucket = "sbtk-sample-bucket"
}
