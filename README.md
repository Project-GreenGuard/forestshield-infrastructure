# ForestShield Infrastructure

Terraform infrastructure as code for AWS resources.

## Overview

This repository contains Terraform configurations for:

- AWS IoT Core (device management, MQTT)
- AWS Lambda functions (sensor processing, API handler)
- AWS DynamoDB (data storage)
- AWS API Gateway (REST API)
- IAM roles and policies

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with hackathon profile
- AWS credentials with permissions for:
  - IoT Core
  - Lambda
  - DynamoDB
  - API Gateway
  - IAM

## Quick Start

### 1. Configure AWS Credentials

**Option A: Using AWS CLI Profile (Recommended)**

```bash
aws configure --profile hackathon
# Enter Access Key ID
# Enter Secret Access Key
# Enter region: us-east-1
# Enter output format: json
```

**Option B: Using Environment Variables**

Copy the environment template:

```bash
cp .env.example .env
```

Edit `.env` with your AWS credentials (provided by team lead):

```bash
# Load environment variables
source .env
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION
```

**Important:** Never commit `.env` files with real credentials. They are in `.gitignore`.

### 2. Package Lambda Functions

**Important**: Package Lambda functions from `forestshield-backend` first:

```bash
# From forestshield-backend directory
cd lambda-processing
zip -r ../../forestshield-infrastructure/lambda-processing.zip . -x "*.pyc" "__pycache__/*" "*.zip"

cd ../api-gateway-lambda
zip -r ../../forestshield-infrastructure/api-gateway-lambda.zip . -x "*.pyc" "__pycache__/*" "*.zip"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan
```

### 5. Deploy

```bash
terraform apply
```

Type `yes` when prompted.

### 6. Get Outputs

After deployment, note these outputs:

- `iot_endpoint_address` - For ESP32 configuration
- `api_endpoint` - For frontend configuration
- `dynamodb_table_name` - Table name

## Infrastructure Components

### IoT Core (`iot-core.tf`)

- IoT Thing for ESP32 devices
- IoT Policy for device permissions
- IoT Rule to trigger Lambda on `wildfire/sensors/+` topic

### Lambda (`lambda.tf`)

- `wildfire-process-sensor-data` - Processes IoT data, fetches NASA FIRMS, calculates risk
- `wildfire-api-handler` - Handles API Gateway requests

### DynamoDB (`dynamodb.tf`)

- `WildfireSensorData` table
- On-demand billing (cost-effective)
- TTL enabled (30 days)

### API Gateway (`apigateway.tf`)

- REST API with three endpoints:
  - `GET /api/sensors`
  - `GET /api/sensor/{id}`
  - `GET /api/risk-map`
- Integrated with Lambda functions
- CORS enabled

### IAM (`iam.tf`)

- Lambda execution role
- DynamoDB access permissions
- Minimal permissions (security best practice)

## Variables

Edit `main.tf` to change:

- `aws_region` - AWS region (default: us-east-1)

## Cost Considerations

Designed to stay within $100 AWS credits:

- DynamoDB: On-demand pricing (pay per request)
- Lambda: Free tier (1M requests/month)
- IoT Core: First 250K messages/month free
- API Gateway: First 1M requests/month free

Monitor costs in AWS Cost Explorer.

## Destroying Infrastructure

**Warning**: This will delete all data!

```bash
terraform destroy
```

## Troubleshooting

### Lambda Deployment Issues

- Ensure zip files are in this directory before `terraform apply`
- Check Lambda function code size limits (50MB zipped)

### Permission Errors

- Verify AWS credentials
- Check IAM permissions
- Ensure hackathon profile has necessary permissions

### Terraform State Issues

```bash
terraform refresh
```

## Related Repositories

- **forestshield-backend** - Lambda function source code
- **forestshield-iot-firmware** - ESP32 devices
- **forestshield-frontend** - Dashboard consuming APIs

## License

See LICENSE file
