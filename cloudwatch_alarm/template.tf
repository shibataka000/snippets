variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# CloudWatch -> SNS -> Lambda
resource "aws_lambda_function" "catch_alarm"{
  filename = "cloudwatch_alarm.zip"
  source_code_hash = "${base64sha256(file("cloudwatch_alarm.zip"))}"

  function_name = "catch_alarm"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.catch_alarm"
  runtime = "python2.7"
}

resource "aws_sns_topic" "alarm" {
  name = "alarm"
}

resource "aws_sns_topic_subscription" "lambda_subscriber" {
  topic_arn = "${aws_sns_topic.alarm.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.catch_alarm.arn}"
}

resource "aws_lambda_permission" "permission" {
  statement_id = "permission"
  function_name = "${aws_lambda_function.catch_alarm.arn}"
  action = "lambda:InvokeFunction"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.alarm.arn}"
}

# Lambda
resource "aws_lambda_function" "raise_exception"{
  filename = "cloudwatch_alarm.zip"
  source_code_hash = "${base64sha256(file("cloudwatch_alarm.zip"))}"

  function_name = "raise_exception"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.raise_exception"
  runtime = "python2.7"
}

resource "aws_cloudwatch_metric_alarm" "error_in_lambda" {
  alarm_name = "error_in_lambda"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  alarm_actions = ["${aws_sns_topic.alarm.arn}"]
}
