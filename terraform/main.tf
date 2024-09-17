provider "aws" {
  profile = "studies"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}
