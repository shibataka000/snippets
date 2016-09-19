variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

# SQS
resource "aws_sqs_queue" "test" {
  name = "test"
}

resource "aws_lambda_function" "subscribe_sqs" {
  function_name = "subscribe_sqs"
  filename = "deploy.zip"
  source_code_hash = "${base64sha256(file("deploy.zip"))}"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.subscribe_sqs"
  runtime = "python2.7"
  timeout = "60"
}

# SNS
resource "aws_sns_topic" "test" {
  name = "test"
}

resource "aws_lambda_function" "subscribe_sns" {
  function_name = "subscribe_sns"
  filename = "deploy.zip"
  source_code_hash = "${base64sha256(file("deploy.zip"))}"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.subscribe_sns"
  runtime = "python2.7"
  timeout = "60"
}

resource "aws_sns_topic_subscription" "lambda_subscriber" {
  topic_arn = "${aws_sns_topic.test.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.subscribe_sns.arn}"
}

resource "aws_lambda_permission" "permission" {
  statement_id = "permission"
  function_name = "${aws_lambda_function.subscribe_sns.arn}"
  action = "lambda:InvokeFunction"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.test.arn}"
}
