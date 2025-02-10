packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "my_vm" {
  region        = "us-west-2"
  source_ami    = "ami-0e532fbed6ef00604"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "my-vm-image-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
}

build {
  sources = [
    "source.amazon-ebs.my_vm"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "pip3 install -r /path/to/your/requirements.txt"
    ]
  }
}
