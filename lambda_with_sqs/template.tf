variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# Lambda
resource "aws_lambda_function" "send" {
  function_name = "send"
  filename = "lambda_with_sqs.zip"
  source_code_hash = "${base64sha256(file("lambda_with_sqs.zip"))}"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.send"
  runtime = "python2.7"
  timeout = "60"
}

# Lambda
resource "aws_lambda_function" "receive" {
  function_name = "receive"
  filename = "lambda_with_sqs.zip"
  source_code_hash = "${base64sha256(file("lambda_with_sqs.zip"))}"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.receive"
  runtime = "python2.7"
  timeout = "60"
}

# SQS
resource "aws_sqs_queue" "queue" {
  name = "test"
}
