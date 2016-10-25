variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_lambda_function" "raise_exception"{
  filename = "lambda_with_git.zip"
  source_code_hash = "${base64sha256(file("lambda_with_git.zip"))}"

  function_name = "lambda_with_git"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python2.7"
  timeout = "60"
}
