variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# Lambda
resource "aws_lambda_function" "lambda_with_cron" {
  filename = "lambda_with_cron.zip"
  source_code_hash = "${base64sha256(file("lambda_with_cron.zip"))}"

  function_name = "lambda_with_cron"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python2.7"
}

resource "aws_lambda_permission" "permission" {
  statement_id = "permission"
  function_name = "${aws_lambda_function.lambda_with_cron.arn}"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.cron.arn}"

  depends_on = ["aws_lambda_function.lambda_with_cron", "aws_cloudwatch_event_rule.cron"]
}

# CloudWatch
resource "aws_cloudwatch_event_rule" "cron" {
  name = "cron"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = "${aws_cloudwatch_event_rule.cron.name}"
  target_id = "lambda_function"
  arn = "${aws_lambda_function.lambda_with_cron.arn}"

  depends_on = ["aws_lambda_function.lambda_with_cron", "aws_cloudwatch_event_rule.cron"]
}
