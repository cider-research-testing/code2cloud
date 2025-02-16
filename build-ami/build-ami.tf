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

# Fetch existing security groups with the given name
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["aws-ami-test3"]
  }
}

# Check if the key pair already exists in AWS
data "aws_key_pair" "existing_key" {
  key_name = "my-key-pair"
}

# Conditionally create the key only if it doesn’t exist
resource "tls_private_key" "my_key" {
  count     = length(data.aws_key_pair.existing_key.id) > 0 ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  count      = length(data.aws_key_pair.existing_key.id) > 0 ? 0 : 1
  key_name   = "my-key-pair"
  public_key = tls_private_key.my_key[0].public_key_openssh
}

# Save the private key locally for SSH access
resource "local_file" "private_key" {
  count    = length(data.aws_key_pair.existing_key.id) > 0 ? 0 : 1
  content  = tls_private_key.my_key[0].private_key_pem
  filename = "${path.module}/my-key.pem"
}

# Conditionally create a new security group only if it does not already exist
resource "aws_security_group" "aws_ami_test3" {
  count = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1

  name        = "aws-ami-test3"
  description = "Security group for aws-ami-test3"
  vpc_id      = "vpc-03049671223312878"

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

resource "aws_instance" "ami_builder" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Replace with a suitable Ubuntu AMI ID for your region
  instance_type = "t3.micro"  # Or a more appropriate instance type
  vpc_security_group_ids = length(data.aws_security_groups.existing_sg.ids) > 0 ? data.aws_security_groups.existing_sg.ids : [aws_security_group.aws_ami_test3[0].id]
  #vpc_security_group_ids = ["${aws_security_group.aws_ami_test3.id}"]
  # Use the existing key or the newly created one
  key_name = length(data.aws_key_pair.existing_key.id) > 0 ? data.aws_key_pair.existing_key.key_name : aws_key_pair.my_key[0].key_name

  tags = {
    Name = "AMI Builder from TF"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Or the appropriate user for your AMI
    host        = self.public_ip
    private_key = length(data.aws_key_pair.existing_key.id) > 0 ? data.aws_key_pair.existing_key.private_key_pem : file("~/.ssh/my-key.pem")
  } 

  provisioner "file" {
    source      = "../main.py"
    destination = "/tmp/main.py"  # Copy script to the instance
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip",  # Install Python (if not already present)
      "sudo python3 /tmp/main.py",  # Execute the script
    ]
  }
}
