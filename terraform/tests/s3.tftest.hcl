variables {
  bucket_prefix = "test"
}

run "uses_root_level_value" {

  command = plan

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "S3 bucket name did not match expected"
  }

}

run "overrides_root_level_value" {

  command = plan

  variables {
    bucket_prefix = "other"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "other-bucket"
    error_message = "S3 bucket name did not match expected"
  }

}
