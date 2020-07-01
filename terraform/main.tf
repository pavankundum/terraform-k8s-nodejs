# Terraform Version
terraform {
  required_version = ">= 0.12"
}

# Terraform Provider
provider "aws" {
  region = var.AWS_REGION
}

# Creation of key-pair to SSH into EC2 instance
resource "aws_key_pair" "nodejs_keypair" {
  key_name   = "nodejs_keypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
  lifecycle {
    ignore_changes = [public_key]
  }
}

# Creation of EC2 instance, copying files and executing shell script to configure minikube, aws and dependencies 
resource "aws_instance" "nodejs_webapp" {
  ami             = var.AMIS[var.AWS_REGION]
  instance_type   = "t2.large"
  key_name        = aws_key_pair.nodejs_keypair.key_name
  subnet_id       = var.PRIVATE_SUBNET1_ID
  security_groups = [var.EC2_SG_ID]
  tags = {
    Name = "nodejs_webapp"
  }

  provisioner "file" {
    source      = "../minikube.sh"
    destination = "/tmp/minikube.sh"
  }
  provisioner "file" {
    source      = "../kube_workloads.yaml"
    destination = "/tmp/kube_workloads.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/minikube.sh",
      "/tmp/minikube.sh"
      #"kubectl apply -f /tmp/kube_workloads.yaml"#
    ]
  }
}

# Creation of ELB, Listners and Health Check
resource "aws_elb" "nodejs-elb" {
  name            = "nodejs-elb"
  subnets         = [var.PUBLIC_SUBNET1_ID, var.PUBLIC_SUBNET2_ID]
  security_groups = [var.ELB_SG_ID]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "nodejs_elb"
  }
}

# Fetching the ELB URL from the output
output "ELB_URL" {
  value = aws_elb.nodejs-elb.dns_name
}
