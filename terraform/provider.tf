provider "aws" {
  region  = "us-east-1"
  profile = "studies"  # Use o perfil que você configurou anteriormente
}

terraform {
  backend "s3" {
    bucket = "terraform-state-career-path"
    key    = "terraform/career_path_terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
