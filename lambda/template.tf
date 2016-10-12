variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# Lambda
resource "aws_lambda_function" "ghw_lambda" {
  filename = "github_webhook.zip"
  source_code_hash = "${base64sha256(file("github_webhook.zip"))}"

  function_name = "github_webhook_test"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.receive"
  runtime = "python2.7"
}
