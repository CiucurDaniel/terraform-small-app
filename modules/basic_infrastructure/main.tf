terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secrect_key
}


# Create VPC
# a virtual isolated network in AWS

resource "aws_vpc" "main_vpc" {
  cidr_block = var.general_cidr_block # 256 addresses - 2  = 254 usabled IP addresses
  instance_tenancy     = "default"
  enable_dns_support   = true # internal domain name
  enable_dns_hostnames = true # internal host name

  tags = {
    Name  = "Main VPC"
    Stage = var.stage
  }
}

# Create Subnet
# create one subnet completely containing all VPC CIDR

# a subnet with a route table that has a route to IG is = public subnet

resource "aws_subnet" "main_public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.general_cidr_block
  #map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name  = "Main Subnet"
    Stage = var.stage
  }
}


# Internet Gateway
# provides a target in VPC route tables for internt routable trafic

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name  = "Main internet gateway"
    Stage = var.stage
  }
}


# Route table
# set of rules that determine where trafic is directed

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }

  tags = {
    Name  = "Main route table"
    Stage = var.stage
  }
}


# Associate route table with public subnet/s

resource "aws_route_table_association" "main_route_table_association" {
  subnet_id      = aws_subnet.main_public_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}



# --------------------
# EC2 instance section
# --------------------


# EC2 Instance
# EC2 instance which will hold our server app

resource "aws_instance" "main_server_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main_server_security_group.id]

  subnet_id = aws_subnet.main_public_subnet.id # make sure my EC2 is in my desired subnet

  user_data = templatefile("${path.module}/server.sh", {
    environment = var.stage
    cidr        = var.general_cidr_block
    server_port = var.server_port
  })


  tags = {
    Name  = "app_server_ec2"
    Stage = var.stage
  }
}


# Security group for EC2

resource "aws_security_group" "main_server_security_group" {
  name = "main_server_security_group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.server_port
    to_port     = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 
  }

  egress {
    protocol    = "-1"  # it means "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
