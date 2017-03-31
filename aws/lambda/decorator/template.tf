provider "aws" {
  region = "ap-northeast-1"
}

# Lambda
resource "aws_lambda_function" "decorator" {
  filename = "project.zip"
  source_code_hash = "${base64sha256(file("project.zip"))}"

  function_name = "decorator"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python2.7"
}
