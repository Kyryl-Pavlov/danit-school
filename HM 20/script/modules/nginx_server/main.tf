# Security Group
resource "aws_security_group" "nginx_sg" {
  name   = "nginx-sg-${var.vpc_id}"
  vpc_id = var.vpc_id

  # Loop through the list of open ports
  dynamic "ingress" {
    for_each = var.list_of_open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Find latest Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# SSH Key Pair
resource "tls_private_key" "nginx" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nginx" {
  key_name   = var.key_name
  public_key = tls_private_key.nginx.public_key_openssh
}

resource "local_sensitive_file" "nginx_key" {
  content  = tls_private_key.nginx.private_key_pem
  filename = "${path.root}/nginx-key.pem"
}

# EC2 Instance with Nginx
resource "aws_instance" "nginx_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nginx.key_name
  
  # User data to install Nginx on boot
  user_data = <<-EOF
              #!/bin/bash
              dnf install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = { Name = "Nginx-Module-Instance" }
}