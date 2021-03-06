# Provider
provider "aws" {
  region = "eu-west-1"
  
}

# Create EC2 Test instance
resource "aws_instance" "test-instance" {
  key_name = "preprod"
  subnet_id = "subnet-c97205af"
  ami = "ami-003056346fbb9b8cf"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  disable_api_termination = "false"
  monitoring = "false"
  vpc_security_group_ids = ["${aws_security_group.test-sg.id}"]
  tags =  {
    Name = "test-instance"
  }
}

# Create Test SG
resource "aws_security_group" "test-sg" {
     vpc_id      = "vpc-20e7dd46"
    name = "test-sg"
    description = "Test Security group"
    tags = {
        Name = "Simple Spin up Instance"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
}
