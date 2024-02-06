
# Terraform AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create AWS VPC in us-east-1
resource "aws_vpc" "vpc-demo-us-east-1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc-demo-us-east-1"
  }
}

# Terraform state in S3 bucket with locking ID

terraform {
  backend "s3" {
    bucket         = "terraform-state-github-actions"
    key            = "/vpc-aws-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vpc-aws-project"
  } 
}

   