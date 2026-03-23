# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "sp-3-terraform-state-danit"

  tags = {
    Name = "sp-3-terraform-state"
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
