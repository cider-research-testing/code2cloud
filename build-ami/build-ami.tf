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

variable "private_key_path" {
  type = string
  description = "Path to your private key file"
  default = "~/.ssh/id_rsa" #Added a default value
}

resource "aws_instance" "ami_builder" {
  ami           = "ami-0c55b9fdcb30b5a97"  # Replace with a suitable Ubuntu AMI ID for your region
  instance_type = "t2.micro"  # Or a more appropriate instance type

  tags = {
    Name = "AMI Builder"
  }

  provisioner "file" {
    source      = "scripts/main.py"
    destination = "/tmp/main.py"  # Copy script to the instance
  }

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
      "sudo apt-get install -y python3 python3-pip",  # Install Python (if not already present)
      "sudo pip3 install boto3", # install boto3
      "sudo python3 /tmp/main.py",  # Execute the script
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Or the appropriate user for your AMI
    private_key = file(var.private_key_path) # Use the private key
    host        = self.public_ip
  }
}

resource "aws_ami" "generated_ami" {
  name        = "my-custom-ami"
  description = "AMI built with Terraform and GitHub Actions"
  virtualization_type = "hvm"
  root_device_name = "/dev/sda1"

  source_instance_id = aws_instance.ami_builder.id
}

resource "null_resource" "cleanup" {
  depends_on = [aws_ami.generated_ami]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.ami_builder.id} --region ${var.aws_region}"
  }
}


output "ami_id" {
  value = aws_ami.generated_ami.id
}
