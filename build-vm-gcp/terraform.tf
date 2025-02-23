terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"  # Or your preferred Google provider version
    }
  }
}

# Generate an SSH key pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally (Optional, useful for SSH access)
resource "local_file" "private_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "${path.module}/my-key.pem"
}

# Create a GCP firewall rule
resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a GCP compute instance
resource "google_compute_instance" "vm_instance" {
  name         = "vm-instance"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.my_key.public_key_openssh}"
  }

  tags = ["allow-ssh"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.network_interface[0].access_config[0].nat_ip
    private_key = tls_private_key.my_key.private_key_pem
  }

  provisioner "file" {
    source      = "../main.py"
    destination = "/tmp/main.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip",
      "sudo python3 /tmp/main.py",
    ]
  }
}

# Note: GCP does not support creating custom images directly through Terraform in the same way as AWS.
# You would typically use Packer or a similar tool to manage image creation in GCP.
