provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "meu-terraform-state-bucket"  # O bucket onde o estado será armazenado
    key    = "terraform/career_path_terraform.tfstate"  # Caminho dentro do bucket
    region = "us-east-1"
    encrypt = true  # Criptografar o arquivo de estado no S3
  }
}

resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"  # Certifique-se de que o nome do bucket é único

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}
