terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-south-1"
}

# -------- VPC ----------
resource "aws_vpc" "trend_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "trend-vpc"
  }
}

# -------- Subnet ----------
resource "aws_subnet" "trend_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

# -------- Internet Gateway ----------
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id
}

# -------- Route Table ----------
resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }
}

resource "aws_route_table_association" "trend_rta" {
  subnet_id      = aws_subnet.trend_subnet.id
  route_table_id = aws_route_table.trend_rt.id
}

# -------- Security Group ----------
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins & SSH"
  vpc_id      = aws_vpc.trend_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# -------- EC2 ----------
resource "aws_instance" "jenkins_ec2" {
  ami           = "ami-00ca570c1b6d79f36" 
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.trend_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name = "trend-key"
    
user_data = <<EOF
#!/bin/bash
yum update -y

# Install Java
yum install -y java-17-amazon-corretto

# Enable Jenkins repo
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
yum install -y jenkins

systemctl enable jenkins
systemctl start jenkins
EOF

  tags = {
    Name = "jenkins-server"
  }
}