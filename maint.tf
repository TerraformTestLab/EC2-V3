terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "existing-vpc" {
  filter {
    name = "tag:Name"
    values = [var.existing_vpc_name]
  }
}

data "aws_instance" "existing-ec2" {
  filter {
    name = "tag:Name"
    values = [var.existing_instance_name]
  }
}

data "aws_security_groups" "existing_sg" {
  filter {
    name = "tag:Name"
    values = [var.existing_security_group_name]
  }
}

resource "random_string" "aws_instance_name" {
  length  = 6
  special = false
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 2048

  provisioner "local-exec" {
    command = "rm -f ${var.key_name}.pem"
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.main.private_key_pem}' > ${var.key_name}.pem"
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh
}

# create a security group to allow SSH from my IP only and also allow the IP value to be passed as a variable if needed
resource "aws_security_group" "allow_ssh" {

  count = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1

  vpc_id = data.aws_vpc.existing-vpc.id
  name   = var.existing_security_group_name

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_inbound_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "ec2-ssh-access"
    can_delete = "true"
    updatedAt = timestamp()
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_instance.existing-ec2.ami
  instance_type = data.aws_instance.existing-ec2.instance_type
  subnet_id     = data.aws_instance.existing-ec2.subnet_id
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh[0].id]
  tags = {
    Name       = "stackc-v3-ec2-insatnce-${random_string.aws_instance_name.result}"
    can_delete = "true"
    key_name   = aws_key_pair.main.key_name
    time = timestamp()
  }
}

resource "null_resource" "private-key-permission-update" {
  depends_on = [aws_instance.main]
  provisioner "local-exec" {
    command = "chmod 400 ${var.key_name}.pem"
  }
}
