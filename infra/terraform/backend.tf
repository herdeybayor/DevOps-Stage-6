terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  # Remote backend configuration for S3
  # To enable: Create S3 bucket and DynamoDB table, then uncomment below
  # One-time setup:
  # ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  # BUCKET="devops-stage6-terraform-state-${ACCOUNT_ID}"
  # aws s3api create-bucket --bucket $BUCKET --region us-east-1
  # aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled
  # aws s3api put-bucket-encryption --bucket $BUCKET --server-side-encryption-configuration '{...}'
  # aws dynamodb create-table --table-name terraform-locks \
  #   --attribute-definitions AttributeName=LockID,AttributeType=S \
  #   --key-schema AttributeName=LockID,KeyType=HASH \
  #   --billing-mode PAY_PER_REQUEST
  # Then uncomment backend block below and run: terraform init -migrate-state

  backend "s3" {
    bucket         = "devops-stage6-terraform-state-785202559067"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Stage-6"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

