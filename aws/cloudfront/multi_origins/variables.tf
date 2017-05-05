variable "region" {
  default = "ap-northeast-1"
}

variable "account_id" {
  default = "370106426606"
}

variable "origin_access_identity" {
  default = "E37B9KIK0WDT36"
}

provider "aws" {
  region = "${var.region}"
}
