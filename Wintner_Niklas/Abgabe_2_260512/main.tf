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

# Diese Variablen ziehen sich die Daten aus den GitHub Secrets
variable "exoscale_key" {}
variable "exoscale_secret" {}

# 1. Sicherheitsgruppe (Firewall)
resource "exoscale_security_group" "vica_sg" {
  name = "vica-sg-wintner-v8"
}

# 2. Regel für Port 80 (HTTP)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.vica_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# 3. Die VM (Compute Instance)
resource "exoscale_compute_instance" "my_vm" {
  name               = "vica-vm-wintner"
  zone               = "at-vie-1"
  type               = "standard.micro"
  # Die aktuelle ID für Ubuntu 26.04 LTS in Wien
  template_id        = "69677353-8167-4638-89c0-3f4439c36203"
  disk_size          = 10
  security_group_ids = [exoscale_security_group.vica_sg.id]
  user_data          = file("cloud-init.yaml")
}

# Zeigt am Ende die IP-Adresse an
output "vm_public_ip" {
  value = exoscale_compute_instance.my_vm.public_ip_address
}
