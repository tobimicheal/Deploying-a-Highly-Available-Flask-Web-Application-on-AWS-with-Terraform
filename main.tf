terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC with public and private subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnets in different Availability Zones
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

# Create private subnets in different Availability Zones
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 2}.0/24"

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

# Attach an Internet Gateway to allow traffic to the public subnets
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a security group to allow HTTP and SSH traffic
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a launch configuration for your EC2 instances and declare the image ID
resource "aws_launch_configuration" "app" {
  image_id        = "ami-007868005aea67c54"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              pip3 install flask
              cat <<EOL > /home/ec2-user/app.py
              from flask import Flask
              app = Flask(__name__)

              @app.route('/')
              def home():
                  return "Hello, this is a Highly Available Flask app on AWS!"

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOL

              python3 /home/ec2-user/app.py &
              EOF
}

## Configure the auto-scaling group
resource "aws_autoscaling_group" "app_asg" {
  launch_configuration = aws_launch_configuration.app.id
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = [aws_subnet.public[0].id, aws_subnet.public[1].id]  # Different AZs
}

# Create the App load balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id]  # Different AZs
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]  # Different AZs

  tags = {
    Name = "DB subnet group"
  }
}

# Deploy the MySQL RDS instance in the private subnet
resource "aws_db_instance" "app_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7.44"  # The correct version
  instance_class         = "db.t3.micro"  # Change instance class
  db_name                = "flaskappdb"
  username               = "admin"
  password               = "yourpassword"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.id
}



data "aws_availability_zones" "available" {}

# Output the RDS instance endpoint
output "db_instance_endpoint" {
  value = aws_db_instance.app_db.endpoint
}

# Output the Load Balancer DNS name
output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output the Auto Scaling Group ID
output "autoscaling_group_id" {
  value = aws_autoscaling_group.app_asg.id
}

