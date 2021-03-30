locals {
  # Calculate values for internal use
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  lambda_name_snake = join("", [for element in split("-", lower(replace(var.lambda_name, "_", "-"))) : title(element)])
}

# Retrieve the AWS region and caller identity to which we are deploying this function
data "aws_region" "default" {}
data "aws_caller_identity" "default" {}

# Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = local.lambda_name_snake
  description = var.lambda_description
  role = aws_iam_role.lambda.arn
  handler = null
  runtime = null
  memory_size = var.lambda_memory
  timeout = var.lambda_timeout
  package_type = "Image"
  image_uri = var.docker_image_uri
  environment {
    variables = merge({
      LAMBDA_FUNCTION_NAME = var.lambda_name,
      LAMBDA_IAM_ROLE_ARN = aws_iam_role.lambda.arn,
      LAMBDA_MEMORY_SIZE = var.lambda_memory,
      LAMBDA_RUNTIME = "Docker"
      LAMBDA_TIMEOUT = var.lambda_timeout
    }, var.lambda_environment_variables)
  }
  vpc_config {
    subnet_ids = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }
  image_config {
    command = var.docker_command
    entry_point = var.docker_entrypoint
    working_directory = var.docker_working_directory
  }
}
