provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/aws/lambda/layer/layer.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_lambda_layer_version" "layer" {
  filename = "layer.zip"
  source_code_hash = filebase64sha256("layer.zip")
  layer_name = "sample"
}

resource "aws_lambda_function" "function" {
  filename = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  function_name = "layer-sample"
  role = "arn:aws:iam::370106426606:role/service-role/lambda"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.6"
  timeout = 300
  memory_size = 1024

  layers = [aws_lambda_layer_version.layer.arn]
}
