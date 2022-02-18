data "archive_file" "lambda_get_people" {
  type = "zip"

  source_dir  = "${path.module}/../../../code/get_people/src/"
  output_path = "${path.module}/get_people.zip"
}

resource "aws_s3_bucket_object" "lambda_get_people" {
  bucket = var.lambda_code_bucket_id

  key = "${var.environment}/lambda_get_people.zip"
  source = data.archive_file.lambda_get_people.output_path

  etag = filemd5(data.archive_file.lambda_get_people.output_path)
}

resource "aws_lambda_function" "get_people" {
  function_name = "${var.environment}-get_people"

  s3_bucket = var.lambda_code_bucket_id
  s3_key    = aws_s3_bucket_object.lambda_get_people.id

  runtime = "python3.8"
  handler = "lambda_handler.handle"

  source_code_hash = data.archive_file.lambda_get_people.output_base64sha256

  role = "arn:aws:iam::${var.aws_account}:role/${var.aws_lambda_execution_role}"
  timeout = 30
}

resource "aws_apigatewayv2_integration" "get_people" {
  api_id = var.api_id

  integration_uri    = aws_lambda_function.get_people.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_people" {
  api_id = var.api_id

  route_key = "GET /skywalker"
  target    = "integrations/${aws_apigatewayv2_integration.get_people.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_people.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_execution_arn}/*/*"
}