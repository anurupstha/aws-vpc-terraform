# Variable for Project ID
variable "project_id" {
  description = "My AWS VPC Project"
  type        = string
  default     = "my-project-id"
}

# Variable for vpc cidr block
variable "vpc_cidr" {
  description = "Public Subnet CIDR Values"
  type        = string
  default     = "10.0.0.0/16"
}

# Variable for cidr public subnet
variable "public_subnet_cidr" {
  description = "Public Subnet CIDR Values"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
# Variable for cidr private subnet
variable "private_subnet_cidr" {
  description = "Private Subnet CIDR Values"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Variable for east-us-1 availability zone
variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1b"]
}


