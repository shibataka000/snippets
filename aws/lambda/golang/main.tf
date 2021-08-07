provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/lambda/golang/golang.tf"
    region = "ap-northeast-1"
  }
}

resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "AWSXRayDaemonWriteAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.lambda.name
}

resource "aws_lambda_function" "go" {
  function_name    = var.name
  role             = aws_iam_role.lambda.arn
  runtime          = "go1.x"
  filename         = "app.zip"
  source_code_hash = filebase64sha256("app.zip")
  handler          = "app"
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_function" "docker" {
  function_name    = "${var.name}-docker"
  role             = aws_iam_role.lambda.arn
  package_type     = "Image"
  image_uri        = "${aws_ecr_repository.lambda.repository_url}:latest"
  source_code_hash = trimprefix(data.aws_ecr_image.lambda.image_digest, "sha256:")
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "go" {
  function_name = aws_lambda_function.go.arn
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron.arn
}

resource "aws_lambda_permission" "docker" {
  function_name = aws_lambda_function.docker.arn
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron.arn
}

resource "aws_cloudwatch_event_rule" "cron" {
  name                = "cron"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "go" {
  rule = aws_cloudwatch_event_rule.cron.name
  arn  = aws_lambda_function.go.arn
}

resource "aws_cloudwatch_event_target" "docker" {
  rule = aws_cloudwatch_event_rule.cron.name
  arn  = aws_lambda_function.docker.arn
}

resource "aws_ecr_repository" "lambda" {
  name = var.name
  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "lambda" {
  repository_name = aws_ecr_repository.lambda.name
  image_tag       = "latest"
}
