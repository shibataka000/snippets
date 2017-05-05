variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_route53_zone" "zone" {
  name = "shibataka000.info."
}

resource "aws_route53_record" "cloudfront" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "google.${data.aws_route53_zone.zone.name}"
  type = "A"
  ttl = "60"
  records = ["216.58.197.163"]  # www.google.co.jp
}
