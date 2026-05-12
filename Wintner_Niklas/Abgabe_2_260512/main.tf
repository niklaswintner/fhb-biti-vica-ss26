terraform {
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
    }
  }
}

provider "exoscale" {
  key    = var.exoscale_key
  secret = var.exoscale_secret
}

variable "exoscale_key" {}
variable "exoscale_secret" {}

# Dynamische Suche: Terraform fragt Exoscale nach dem Template
data "exoscale_template" "ubuntu" {
  zone = "at-vie-1"
  name = "Linux Ubuntu 24.04 LTS 64-bit"
}

# 1. Sicherheitsgruppe
resource "exoscale_security_group" "vica_sg" {
  name = "vica-sg-wintner-v9"
}

# 2. Regel für Port 80
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vica_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# 3. Die VM
resource "exoscale_compute_instance" "my_vm" {
  name               = "vica-vm-wintner"
  zone               = "at-vie-1"
  type               = "standard.micro"
  # Hier wird das Ergebnis der Suche oben genutzt
  template_id        = data.exoscale_template.ubuntu.id
  disk_size          = 10
  security_group_ids = [exoscale_security_group.vica_sg.id]
  user_data          = file("cloud-init.yaml")
}

output "vm_public_ip" {
  value = exoscale_compute_instance.my_vm.public_ip_address
}
