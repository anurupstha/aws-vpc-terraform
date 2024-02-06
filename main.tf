
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
    key            = "vpc-aws-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vpc-aws-project"
  } 
}

# Create Public Subnet
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.vpc-demo-us-east-1.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "Subnet-Public: Public Subnet-${count.index + 1}"
  }
}

# Create private subnet 
resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.vpc-demo-us-east-1.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "Subnet-Private: Private Subnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.vpc-demo-us-east-1.id
  tags = {
    Name = "IGW: For aws-vpc-project"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.public_subnet_cidr)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id
  tags = {
    Name = "NAT-Gateway: For aws-vpc-project"
  }
}
# Elastic IP for the NAT gateway
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidr)
  vpc = true
}
