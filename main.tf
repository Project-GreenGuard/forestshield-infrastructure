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
  # Make sure to configure: aws configure --profile GreenGuard
  default_tags {
    tags = {
      Project     = "GreenGuard"
      Environment = var.environment
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

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "forestshield"
}

# Local values for environment-specific naming
locals {
  env_suffix = var.environment == "production" ? "" : "-${var.environment}"
  table_name = "WildfireSensorData${local.env_suffix}"
}

# Outputs
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.wildfire_sensor_data.name
}

output "lambda_processing_function" {
  description = "Lambda function name for sensor processing"
  value       = aws_lambda_function.process_sensor_data.function_name
}

output "lambda_api_function" {
  description = "Lambda function name for API handler"
  value       = aws_lambda_function.api_handler.function_name
}

data "aws_iot_endpoint" "wildfire" {
  endpoint_type = "iot:Data-ATS"
}

output "iot_core_endpoint" {
  value = data.aws_iot_endpoint.wildfire.endpoint_address
}

