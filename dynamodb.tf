# DynamoDB table for storing sensor data

resource "aws_dynamodb_table" "wildfire_sensor_data" {
  name           = "WildfireSensorData"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing (cost-effective for low traffic)
  hash_key       = "deviceId"
  range_key      = "timestamp"

  attribute {
    name = "deviceId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  # TTL for automatic cleanup of old data
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "WildfireSensorData"
    Environment = "capstone"
    Project     = "GreenGuard"
  }
}

