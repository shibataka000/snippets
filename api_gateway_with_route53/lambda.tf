resource "aws_lambda_function" "lambda" {
  filename = "project.zip"
  source_code_hash = "${base64sha256(file("project.zip"))}"

  function_name = "sample"
  role = "arn:aws:iam::370106426606:role/lambda_basic_execution"
  handler = "lambda_handler.run"
  runtime = "python2.7"
}

resource "aws_lambda_permission" "permission" {
  statement_id = "lambda_permission"
  function_name = "${aws_lambda_function.lambda.arn}"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/sample"
}
