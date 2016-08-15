resource "aws_api_gateway_rest_api" "api" {
  name = "sample"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"

  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "sample"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"

  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  status_code = "200"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations",
  integration_http_method = "GET"

  depends_on = ["aws_lambda_function.lambda"]
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.method_response.status_code}"

  depends_on = ["aws_api_gateway_integration.integration"]
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "dev"

  depends_on = [
    "aws_api_gateway_rest_api.api",
    "aws_api_gateway_method.method",
    "aws_api_gateway_method_response.method_response",
    "aws_api_gateway_integration.integration",
    "aws_api_gateway_integration_response.integration_response"
  ]
}
