#!/bin/bash

# AWS Infrastructure Setup Script
# This script helps set up the AWS backend for Terraform

set -e

echo "======================================"
echo "DevOps Stage 6 - AWS Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    echo "  macOS: brew install awscli"
    echo "  Ubuntu: sudo apt-get install awscli"
    echo "  pip: pip install awscli"
    exit 1
fi
print_success "AWS CLI is installed"

# Check AWS credentials
echo ""
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured or invalid"
    echo "Please run: aws configure"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
print_success "AWS credentials valid"
print_success "Account ID: $AWS_ACCOUNT_ID"
print_success "Region: $AWS_REGION"

# Get bucket name
echo ""
read -p "Enter S3 bucket name for Terraform state (default: devops-stage6-terraform-state-$USER): " BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-"devops-stage6-terraform-state-$USER"}

# Check if bucket exists
echo ""
echo "Checking if bucket exists..."
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket: $BUCKET_NAME"
    
    if [ "$AWS_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    print_success "S3 bucket created"
else
    print_warning "S3 bucket already exists"
fi

# Enable versioning
echo "Enabling bucket versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
print_success "Bucket versioning enabled"

# Enable encryption
echo "Enabling bucket encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
print_success "Bucket encryption enabled"

# Create DynamoDB table for state locking
echo ""
echo "Creating DynamoDB table for state locking..."
TABLE_NAME="terraform-state-lock"

if aws dynamodb describe-table --table-name "$TABLE_NAME" &> /dev/null; then
    print_warning "DynamoDB table already exists"
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$AWS_REGION"
    
    echo "Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME"
    print_success "DynamoDB table created"
fi

# Update backend.tf
echo ""
echo "Updating backend.tf configuration..."
BACKEND_CONFIG="terraform {
  required_version = \">= 1.0\"

  required_providers {
    aws = {
      source  = \"hashicorp/aws\"
      version = \"~> 5.0\"
    }
    local = {
      source  = \"hashicorp/local\"
      version = \"~> 2.4\"
    }
    null = {
      source  = \"hashicorp/null\"
      version = \"~> 3.2\"
    }
  }

  backend \"s3\" {
    bucket         = \"$BUCKET_NAME\"
    key            = \"terraform.tfstate\"
    region         = \"$AWS_REGION\"
    dynamodb_table = \"$TABLE_NAME\"
    encrypt        = true
  }
}

provider \"aws\" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = \"DevOps-Stage-6\"
      ManagedBy   = \"Terraform\"
      Environment = var.environment
    }
  }
}"

echo "$BACKEND_CONFIG" > infra/terraform/backend.tf
print_success "backend.tf updated"

echo ""
echo "======================================"
echo "AWS Setup Complete!"
echo "======================================"
echo ""
echo "Configuration:"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $TABLE_NAME"
echo "  Region: $AWS_REGION"
echo ""
echo "Next steps:"
echo "1. Configure Terraform variables:"
echo "   cd infra/terraform"
echo "   cp terraform.tfvars.example terraform.tfvars"
echo "   nano terraform.tfvars"
echo ""
echo "2. Initialize Terraform:"
echo "   terraform init"
echo ""
echo "3. Plan infrastructure:"
echo "   terraform plan"
echo ""
echo "4. Apply infrastructure:"
echo "   terraform apply"
echo ""
print_success "Ready to deploy infrastructure!"

