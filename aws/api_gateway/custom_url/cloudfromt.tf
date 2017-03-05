resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.bucket.id}.s3.amazonaws.com"
    origin_id = "${aws_s3_bucket.bucket.id}"
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${var.origin_access_identity}"
    }
  }
  origin {
    domain_name = "${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id = "${aws_api_gateway_rest_api.api.id}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "http-only"
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
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  cache_behavior {
    path_pattern = "dev/*"
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${aws_api_gateway_rest_api.api.id}"
    forwarded_values {
      query_string = false
      cookies {
	forward = "none"
      }
    }
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
