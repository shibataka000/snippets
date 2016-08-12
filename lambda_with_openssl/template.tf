variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# Lambda
resource "aws_lambda_function" "lambda_with_openssl" {
  filename = "lambda_with_openssl.zip"
  source_code_hash = "${base64sha256(file("lambda_with_openssl.zip"))}"

  function_name = "lambda_with_openssl"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python2.7"
}
