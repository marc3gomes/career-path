# Criação do Bucket S3
resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"  # Nome do bucket S3

  force_destroy = true

  tags = {
    Name        = "Career Path Data Bucket"
    Environment = "Dev"
  }
}

# Criação do Glue Database
resource "aws_glue_catalog_database" "career_path_db" {
  name = "career_path_db"
}

# Criação do Glue Crawler para detectar automaticamente o esquema e criar a tabela
resource "aws_glue_crawler" "career_path_crawler" {
  name          = "career-path-crawler"
  role          = "arn:aws:iam::<your-aws-account-id>:role/GlueServiceRole"  # Substitua pelo ARN do IAM Role existente
  database_name = aws_glue_catalog_database.career_path_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.career_path.bucket}/data/"  # Diretório S3 com os dados
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping": {
      "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
  })
}
