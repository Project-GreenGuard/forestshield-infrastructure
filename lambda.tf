# AWS Lambda functions for sensor processing and API Gateway

# Lambda function for processing sensor data from IoT Core
resource "aws_lambda_function" "process_sensor_data" {
  filename      = "${path.module}/lambda-processing.zip"
  function_name = "wildfire-process-sensor-data${local.env_suffix}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "process_sensor_data.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  source_code_hash = fileexists("${path.module}/lambda-processing.zip") ? filebase64sha256("${path.module}/lambda-processing.zip") : null

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.wildfire_sensor_data.name
    }
  }
}

# Lambda function for API Gateway endpoints
resource "aws_lambda_function" "api_handler" {
  filename      = "${path.module}/api-gateway-lambda.zip"
  function_name = "wildfire-api-handler${local.env_suffix}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "api_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  source_code_hash = fileexists("${path.module}/api-gateway-lambda.zip") ? filebase64sha256("${path.module}/api-gateway-lambda.zip") : null

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.wildfire_sensor_data.name
    }
  }
}

# Permission for IoT Core to invoke processing Lambda
resource "aws_lambda_permission" "iot_invoke" {
  statement_id  = "AllowExecutionFromIoT"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_sensor_data.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.sensor_data_rule.arn
}

# Permission for API Gateway to invoke API handler Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wildfire_api.execution_arn}/*/*"
}

