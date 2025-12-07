# API Gateway for dashboard endpoints

resource "aws_api_gateway_rest_api" "wildfire_api" {
  name        = "wildfire-api${local.env_suffix}"
  description = "API Gateway for GreenGuard Wildfire Response System"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway resources
# Create /api resource
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  parent_id   = aws_api_gateway_rest_api.wildfire_api.root_resource_id
  path_part   = "api"
}

# Create /api/sensors
resource "aws_api_gateway_resource" "sensors" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "sensors"
}

# Create /api/sensor (singular)
resource "aws_api_gateway_resource" "sensor" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "sensor"
}

# Create /api/sensor/{id}
resource "aws_api_gateway_resource" "sensor_id" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  parent_id   = aws_api_gateway_resource.sensor.id
  path_part   = "{id}"
}

# Create /api/risk-map
resource "aws_api_gateway_resource" "risk_map" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "risk-map"
}

# GET /api/sensors
resource "aws_api_gateway_method" "get_sensors" {
  rest_api_id   = aws_api_gateway_rest_api.wildfire_api.id
  resource_id   = aws_api_gateway_resource.sensors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_sensors" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  resource_id = aws_api_gateway_resource.sensors.id
  http_method = aws_api_gateway_method.get_sensors.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

# GET /api/sensor/{id}
resource "aws_api_gateway_method" "get_sensor" {
  rest_api_id   = aws_api_gateway_rest_api.wildfire_api.id
  resource_id   = aws_api_gateway_resource.sensor_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_sensor" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  resource_id = aws_api_gateway_resource.sensor_id.id
  http_method = aws_api_gateway_method.get_sensor.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

# GET /api/risk-map
resource "aws_api_gateway_method" "get_risk_map" {
  rest_api_id   = aws_api_gateway_rest_api.wildfire_api.id
  resource_id   = aws_api_gateway_resource.risk_map.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_risk_map" {
  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
  resource_id = aws_api_gateway_resource.risk_map.id
  http_method = aws_api_gateway_method.get_risk_map.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "wildfire_api" {
  depends_on = [
    aws_api_gateway_method.get_sensors,
    aws_api_gateway_method.get_sensor,
    aws_api_gateway_method.get_risk_map,
    aws_api_gateway_integration.get_sensors,
    aws_api_gateway_integration.get_sensor,
    aws_api_gateway_integration.get_risk_map,
  ]

  rest_api_id = aws_api_gateway_rest_api.wildfire_api.id
}

# Stage (explicit stage resource to avoid deprecation warning)
resource "aws_api_gateway_stage" "wildfire_api" {
  deployment_id = aws_api_gateway_deployment.wildfire_api.id
  rest_api_id   = aws_api_gateway_rest_api.wildfire_api.id
  stage_name    = var.environment == "production" ? "prod" : var.environment
}

# Output API endpoint
output "api_endpoint" {
  value       = "${aws_api_gateway_stage.wildfire_api.invoke_url}/api"
  description = "Base API endpoint URL (includes /api prefix)"
}

