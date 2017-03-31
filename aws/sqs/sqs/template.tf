variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# SQS
resource "aws_sqs_queue" "queue" {
  name = "test"
}
