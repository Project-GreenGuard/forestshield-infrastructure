# Additional outputs

output "iot_endpoint_address" {
  description = "AWS IoT Core endpoint address for MQTT connections"
  value       = data.aws_iot_endpoint.wildfire.endpoint_address
}

