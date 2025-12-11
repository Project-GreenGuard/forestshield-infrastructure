# AWS IoT Core configuration
# Creates IoT Core thing, certificate, and policy for ESP32 devices
# 
# Note: This creates 3 IoT Things. Each device needs its own certificate/key pair.
# Certificates must be created manually in AWS IoT Core Console for each thing:
# - esp32-wildfire-sensor-1
# - esp32-wildfire-sensor-2
# - esp32-wildfire-sensor-3
# Each certificate must be attached to the corresponding thing and the policy.

resource "aws_iot_thing" "wildfire_sensor" {
  name  = "esp32-wildfire-sensor-${count.index + 1}"
  count = 3 # Total of 3 sensors

  attributes = {
    Type  = "WildfireSensor"
    Model = "ESP32-DHT11"
  }
}

# IoT Policy - allows devices to connect and publish
resource "aws_iot_policy" "sensor_policy" {
  name = "WildfireSensorPolicy${local.env_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Resource = "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# IoT Rule - triggers Lambda when sensor data is received
resource "aws_iot_topic_rule" "sensor_data_rule" {
  name        = "wildfire_sensor_data_rule${replace(local.env_suffix, "-", "_")}"
  description = "Route sensor data to Lambda for processing"
  enabled     = true
  sql         = "SELECT * FROM 'wildfire/sensors/+'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_sensor_data.arn
  }
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

