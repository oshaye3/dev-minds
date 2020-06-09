provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.7"
}

terraform {
  required_version = ">= 0.12.12"

  backend "s3" {
    bucket  = "dm-vpc-states"
    key     = "michael/tftest.tfstat"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

resource "aws_security_group" "blueprint_sg_res" {
  name        = "var.project_name-sg"
  description = "firewall rules"
  vpc_id      = "var.target_vpc"

  # We might need other ports here as well based on dm team
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

# Server Definition
resource "aws_instance" "TeamParisFrontEndServer" {
  ami                    = "var.aws_ami"
  instance_type          = "var.server_type"
  vpc_security_group_ids = ["aws_security_group.blueprint_sg_res.id", ]
  key_name               = "var.target_keypairs"
  subnet_id              = "var.target_subnet"

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = "${file("./preprod.pem")}"
    timeout     = "3m"
    host        = "self.public_ip"
    #host        = "self.private_ip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  tags = {
    Name        = "var.project_name-server"
    Environment = "Production"
    App         = "DevmindTraining"
  }
}

output "pub_ip" {
  value      = ["aws_instance.TeamParisFrontEndServer.public_ip"]
  depends_on = [aws_instance.TeamParisFrontEndServer]
}
