resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "sp-3-jenkins-key"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

# Automatically save the private key as a .pem file locally
resource "local_file" "private_key" {
  content         = tls_private_key.jenkins_key.private_key_pem
  filename        = "${path.module}/sp-3-jenkins-key.pem"
}
