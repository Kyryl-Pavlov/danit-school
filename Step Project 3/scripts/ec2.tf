data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 4. Jenkins Master (On-Demand)
resource "aws_instance" "master" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.master_instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = { Name = "sp-3-jenkins-master" }
}

# 5. Jenkins Worker (On-Demand)
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = { Name = "sp-3-jenkins-worker" }
}
