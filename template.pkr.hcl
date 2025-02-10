
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "my_vm" {
  region        = "us-east-1"
  source_ami    = "ami-085ad6ae776d8f09c"
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"
  ami_name      = "my-vm-image-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

  temporary_key_pair_type = "ed25519" 
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
