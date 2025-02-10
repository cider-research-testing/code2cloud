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
  source_ami    = "ami-0e532fbed6ef00604"
  instance_type = "t2.small"
  ssh_username  = "ubuntu"
  ami_name      = "my-vm-image-${formatdate("YYYYMMDD-hhmmss", timestamp())}"

 
launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Specify UEFI boot mode
  boot_mode = "uefi"

  # Ensure the source AMI supports UEFI
  # You might need to change the source_ami to a UEFI-compatible image
  imds_support = "v2.0"
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
