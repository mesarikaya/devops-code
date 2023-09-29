# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create an AMI data for latest linux image from amazon
data "aws_ami" "latest_amazon_linux_x86" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2_key_pair"
  public_key = file(var.ec2_public_key)
}

resource "aws_security_group" "ec2_instance_sg" {
  name_prefix = "ec2-"
  description = "Security group for EC2 instances"
  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh_inbound" {
  security_group_id = aws_security_group.ec2_instance_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ec2_ssh_outbound" {
  security_group_id = aws_security_group.ec2_instance_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "linux_instance" {
  ami                    = data.aws_ami.latest_amazon_linux_x86.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]

  tags = {
    Name = "InitialEC2Instance"
  }
}