terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Or your preferred AWS provider version
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"  # Replace with your desired region
  description = "AWS region to deploy to"
}

resource "aws_instance" "ami_builder" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Replace with a suitable Ubuntu AMI ID for your region
  instance_type = "t3.micro"  # Or a more appropriate instance type

  tags = {
    Name = "AMI Builder"
  }

  #provisioner "file" {
  #  source      = "main.py"
  #  destination = "/tmp/main.py"  # Copy script to the instance
  #}

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip",  # Install Python (if not already present)
      "sudo python3 /tmp/main.py",  # Execute the script
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo python3 /tmp/main.py",  # Execute the script
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Or the appropriate user for your AMI
    host        = self.public_ip
  }

  # Create temporary security group
  resource "aws_security_group" "temp" {
    name        = "temp-sg-${random_string.suffix.result}"
    description = "Temporary security group for AMI creation"
  
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
}
