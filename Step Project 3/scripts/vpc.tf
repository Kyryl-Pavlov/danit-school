# 1. VPC & Networking
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = var.vpc_cidr

  tags = { Name = "sp-3-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = { Name = "sp-3-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "sp-3-public-rt" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = { Name = "sp-3-public-subnet" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = var.private_subnet_cidr

  tags = { Name = "sp-3-private-subnet" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = { Name = "sp-3-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = { Name = "sp-3-nat-gateway" }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "sp-3-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}
