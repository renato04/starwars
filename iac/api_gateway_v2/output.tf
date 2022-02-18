output "api_execution_arn" {
  value = aws_apigatewayv2_api.skywalker_rest.execution_arn
}

output "api_id" {
  value = aws_apigatewayv2_api.skywalker_rest.id
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.stage.invoke_url
}