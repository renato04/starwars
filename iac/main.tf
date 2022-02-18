resource "aws_s3_bucket" "lambda_code_bucket" {
    bucket = "${var.environment}-lightex-lambda-code"
}


module "api" {
    source = "./api_gateway_v2"
    environment = var.environment
}


module "lambda_get_people" {
    source = "./lambda/get_people"
    aws_lambda_execution_role            =  var.aws_lambda_execution_role
    aws_account         =  var.aws_account
    lambda_code_bucket_id    = aws_s3_bucket.lambda_code_bucket.id
    environment = var.environment
    api_execution_arn = module.api.api_execution_arn
    api_id = module.api.api_id
}
