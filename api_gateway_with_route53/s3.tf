resource "aws_s3_bucket" "bucket" {
  bucket = "sbtk-sample-bucket"
  policy = "${file("policy.json")}"
}
