# terraform {
#   backend "s3" {
#     bucket = "terraform-state-danit-kpavlov"
#     key    = "kyryl_pavlov/terraform.tfstate"
#     region = "eu-central-1"
#   }
# }

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state-danit-kpavlov"
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

provider "aws" {
  region = "eu-central-1"
}

module "my_nginx" {
  source             = "./modules/nginx_server"
  vpc_id             = aws_vpc.main.id
  list_of_open_ports = [80, 443, 22]
  subnet_id          = aws_subnet.public.id
  key_name           = "my-terraform-key"
}

output "nginx_url" {
  value = "http://${module.my_nginx.instance_public_ip}"
}