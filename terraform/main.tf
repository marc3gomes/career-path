provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"  # Certifique-se de que o nome do bucket é único

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}
