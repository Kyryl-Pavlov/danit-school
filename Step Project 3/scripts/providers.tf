terraform {
  # To use S3 backend, uncomment the backend block below AFTER creating the S3 bucket.
  backend "s3" {
    bucket  = "sp-3-terraform-state-danit"
    key     = "global/s3/terraform.tfstate"
    region  = "eu-central-1" # Update this to your bucket's region
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}