#!/bin/bash
# Script to fix Terraform state for staging deployment
# This removes production resources from state so staging can be created

set -e

echo "🔧 Fixing Terraform state for staging deployment..."
echo ""

# Check if we're deploying staging
if [ "$1" != "staging" ]; then
  echo "⚠️  This script is for staging deployment only"
  echo "Usage: ./fix-state.sh staging"
  exit 1
fi

echo "📋 Removing production resources from Terraform state..."
echo "   (These will remain in AWS but won't be managed by this Terraform config)"
echo ""

# Remove IAM role from state (will be recreated with -staging suffix)
if terraform state list | grep -q "aws_iam_role.lambda_role"; then
  echo "  - Removing aws_iam_role.lambda_role from state..."
  terraform state rm aws_iam_role.lambda_role || true
fi

# Remove IAM role policy from state
if terraform state list | grep -q "aws_iam_role_policy.lambda_dynamodb"; then
  echo "  - Removing aws_iam_role_policy.lambda_dynamodb from state..."
  terraform state rm aws_iam_role_policy.lambda_dynamodb || true
fi

# Remove IAM role policy attachment from state
if terraform state list | grep -q "aws_iam_role_policy_attachment.lambda_basic"; then
  echo "  - Removing aws_iam_role_policy_attachment.lambda_basic from state..."
  terraform state rm aws_iam_role_policy_attachment.lambda_basic || true
fi

# Remove S3 bucket from state (if it exists)
if terraform state list | grep -q "aws_s3_bucket.frontend"; then
  echo "  - Removing aws_s3_bucket.frontend from state..."
  terraform state rm aws_s3_bucket.frontend || true
  terraform state rm aws_s3_bucket_versioning.frontend || true
  terraform state rm aws_s3_bucket_website_configuration.frontend || true
  terraform state rm aws_s3_bucket_public_access_block.frontend || true
  terraform state rm aws_s3_bucket_ownership_controls.frontend || true
  terraform state rm aws_s3_bucket_acl.frontend || true
  terraform state rm aws_s3_bucket_policy.frontend || true
fi

# Remove IoT policy from state (if it exists)
if terraform state list | grep -q "aws_iot_policy.sensor_policy"; then
  echo "  - Removing aws_iot_policy.sensor_policy from state..."
  terraform state rm aws_iot_policy.sensor_policy || true
fi

echo ""
echo "✅ State cleanup complete!"
echo ""
echo "Now you can run:"
echo "  terraform plan -var='environment=staging'"
echo "  terraform apply -var='environment=staging'"

