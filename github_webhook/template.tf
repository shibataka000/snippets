variable "region" {
  default = "ap-northeast-1"
}

variable "account_id" {
  default = "370106426606"
}

provider "aws" {
  region = "${var.region}"
}

# API Gateway
resource "aws_api_gateway_rest_api" "ghw_api" {
  name = "GitHub webhook test"
}

resource "aws_api_gateway_resource" "ghw_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"

  parent_id = "${aws_api_gateway_rest_api.ghw_api.root_resource_id}"
  path_part = "webhook"
}

resource "aws_api_gateway_method" "ghw_method" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"
  resource_id = "${aws_api_gateway_resource.ghw_resource.id}"

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "ghw_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"
  resource_id = "${aws_api_gateway_resource.ghw_resource.id}"
  http_method = "${aws_api_gateway_method.ghw_method.http_method}"

  status_code = "200"
}

resource "aws_api_gateway_integration" "ghw_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"
  resource_id = "${aws_api_gateway_resource.ghw_resource.id}"
  http_method = "${aws_api_gateway_method.ghw_method.http_method}"
  
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.ghw_lambda.arn}/invocations",
  integration_http_method = "POST"

  depends_on = ["aws_lambda_function.ghw_lambda"]
}

resource "aws_api_gateway_integration_response" "ghw_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"
  resource_id = "${aws_api_gateway_resource.ghw_resource.id}"
  http_method = "${aws_api_gateway_method.ghw_method.http_method}"
  status_code = "${aws_api_gateway_method_response.ghw_method_response.status_code}"

  depends_on = ["aws_api_gateway_integration.ghw_integration"]
}

resource "aws_api_gateway_deployment" "ghw_deploy" {
  rest_api_id = "${aws_api_gateway_rest_api.ghw_api.id}"
  stage_name = "dev"

  depends_on = [
    "aws_api_gateway_rest_api.ghw_api",
    "aws_api_gateway_method.ghw_method",
    "aws_api_gateway_method_response.ghw_method_response",
    "aws_api_gateway_integration.ghw_integration",
    "aws_api_gateway_integration_response.ghw_integration_response"
  ]
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

resource "aws_lambda_permission" "ghw_lambda_permission" {
  statement_id = "ghw_lambda_permission"
  function_name = "${aws_lambda_function.ghw_lambda.arn}"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.ghw_api.id}/*/POST/webhook"
}

output "url" {
  value = "https://${aws_api_gateway_rest_api.ghw_api.id}.execute-api.${var.region}.amazonaws.com/dev/webhook"
}
