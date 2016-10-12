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

# S3
resource "aws_s3_bucket" "bucket" {
  bucket = "sbtk-sample-bucket"
  policy = "${file("policy.json")}"
}

# CloudFront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.bucket.id}.s3.amazonaws.com"
    origin_id = "${aws_s3_bucket.bucket.id}"
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${var.origin_access_identity}"
    }
  }
  enabled = true
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.bucket.id}"
    forwarded_values {
      query_string = false
      cookies {
	forward = "none"
      }
    }
    trusted_signers = ["${var.account_id}"]
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

