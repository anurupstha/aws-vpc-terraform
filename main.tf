
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

# Elastic IPs for the NAT Gateways
resource "aws_eip" "nat_eip" {
  count = length(var.private_subnet_cidr)
  vpc = true
}

# Create NAT Gateway for private subnet
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.private_subnet_cidr)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.private-subnet[count.index].id
  tags = {
    Name = "Private NAT GW: For aws-vpc-project"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc-demo-us-east-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_internet_gateway.id
  }
    tags = {
        Name = "RT Public Route Table: For aws-vpc-project"
    }
}    

# Create Route table for private subnet
resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.vpc-demo-us-east-1.id
  depends_on = [ aws_nat_gateway.nat_gateway ]
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
    }
    tags = {
      Name = "RT Private Route Table: For aws-vpc-project"
    }
}
# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count = length(var.public_subnet_cidr)
  depends_on = [ aws_subnet.public-subnet, aws_route_table.public_route_table ]
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
# Associate the Private Route tables to each of their respective AZs
resource "aws_route_table_association" "private_rt_assoc" {
  count = length(var.private_subnet_cidr)
  depends_on = [ aws_subnet.private-subnet, aws_route_table.private_route_table ]
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}


 
