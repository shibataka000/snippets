provider "aws" {
  region = "ap-northeast-1"
}

# Lambda
resource "aws_lambda_function" "kms_sample" {
  filename = "project.zip"
  source_code_hash = "${base64sha256(file("project.zip"))}"

  function_name = "kms_sample"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python3.6"
  timeout = "300"

  environment {
    variables = {
      NAME = "AQECAHjGbQ8Uk8o9NTK9aajgH/cWfNqSajh1io1mPGtmJVTb0AAAAGEwXwYJKoZIhvcNAQcGoFIwUAIBADBLBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDJ80IUDJjAsW79sJ8wIBEIAeO56FwSFy8sSzcBRpSel2SKGLaZUFfSOCvNXoopis"
    }
  }
}
