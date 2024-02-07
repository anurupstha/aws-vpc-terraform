data "aws_subnet" "public_subnet" {
 filter {
   name   = "tag:Name"
   values = ["Subnet-Public: Public Subnet-1"]
 }
 depends_on = [aws_route_table_association.public_rt_assoc]
}
#Deploy EC2 instance in the public subnet
resource "aws_instance" "public_ec2" {
 ami           = "ami-0c7217cdde317cfec"
 instance_type = "t2.micro"
 subnet_id     = data.aws_subnet.public_subnet.id
 vpc_security_group_ids = [aws_security_group.public_sg]
 key_name      = "terraform"
 user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2
              echo '<h1>Hello, World!</h1>' | sudo tee /var/www/html/index.html
              EOF
 tags = {
   Name = "Public EC2: For aws-vpc-project"
 }
}

 