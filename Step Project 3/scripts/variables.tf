variable "region" { default = "eu-central-1" }
variable "key_pair" { default = "my-terraform-key" }

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "master_instance_type" {
  description = "Instance type for the Jenkins master"
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Instance type for the Jenkins worker"
  default     = "t2.micro"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access Jenkins"
  default     = "0.0.0.0/0"
}