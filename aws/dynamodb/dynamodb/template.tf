variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name = "HTTP_Cache"
  read_capacity = 5
  write_capacity = 5
  hash_key = "url"
  attribute {
    name = "url"
    type = "S"
  }
}
