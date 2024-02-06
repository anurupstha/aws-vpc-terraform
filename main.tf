# Terraform AWS provider
provider "aws" {
  region = "us-west-1"
}

# Create AWS VPC in us-west-1
resource "aws_vpc" "vpc-demo-us-west-1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc-demo-us-west-1"
  }
}