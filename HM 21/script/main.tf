provider "aws" {
  region = "us-east-1"
}

# 1. Security Group for SSH and HTTP
resource "aws_security_group" "ansible_nodes" {
  name = "ansible-nodes-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 2. EC2 Instances
resource "aws_instance" "nodes" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ansible_nodes.id]
  key_name               = "my-terraform-key"

  tags = {
    Name = "Ansible-Node-${count.index}"
  }
}

# 3. Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tftpl", {
    ip_addrs = aws_instance.nodes.*.public_ip
  })
  filename = "inventory.ini"
}