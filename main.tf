# Main Terraform configuration
# Provider and basic settings

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Backend configuration for state management
  # Uncomment if using remote state (S3, etc.)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "wildfire-system/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  # Use default credentials from AWS CLI profile
  # Make sure to configure: aws configure --profile hackathon
  default_tags {
    tags = {
      Project     = "GreenGuard"
      Environment = "capstone"
      ManagedBy   = "Terraform"
    }
  }
}

# Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# Outputs
output "dynamodb_table_name" {
  value = aws_dynamodb_table.wildfire_sensor_data.name
}

output "lambda_processing_function" {
  value = aws_lambda_function.process_sensor_data.function_name
}

output "lambda_api_function" {
  value = aws_lambda_function.api_handler.function_name
}

data "aws_iot_endpoint" "wildfire" {
  endpoint_type = "iot:Data-ATS"
}

output "iot_core_endpoint" {
  value = data.aws_iot_endpoint.wildfire.endpoint_address
}

