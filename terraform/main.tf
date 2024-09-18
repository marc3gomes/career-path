# Criação do Bucket S3
resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"  # Nome do bucket S3

  force_destroy = true

  tags = {
    Name        = "Career Path Data Bucket"
    Environment = "Dev"
  }
}

# Criação do Bucket S3 para Resultados do Athena
resource "aws_s3_bucket" "athena_results" {
  bucket = "athena-query-results-career-path"

  force_destroy = true

  tags = {
    Name        = "Athena Query Results"
    Environment = "Dev"
  }
}

# Criação do Glue Database
resource "aws_glue_catalog_database" "career_path_db" {
  name = "career_path_db"
}

# Criação do Glue Crawler para detectar automaticamente o esquema
resource "aws_glue_crawler" "career_path_crawler" {
  name          = "career-path-crawler"
  role          = aws_iam_role.glue_role.arn  # O Role do Glue
  database_name = aws_glue_catalog_database.career_path_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.career_path.bucket}/data/"  # Caminho S3 onde os dados estão
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping": {
      "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
  })

  # Opcional: agendamento para rodar diariamente ao meio-dia
  schedule = "cron(0 12 * * ? *)"
}

# Criação do IAM Role para o Glue
resource "aws_iam_role" "glue_role" {
  name = "glue-service-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Política inline do IAM Role para o Glue acessar o S3
resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "GlueS3AccessPolicy"
  role = aws_iam_role.glue_role.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.career_path.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.career_path.bucket}/*"
        ]
      }
    ]
  }
  EOF
}

# Adicionando a política para permitir que o Glue passe a função IAM (PassRole)
resource "aws_iam_policy" "glue_pass_role_policy" {
  name = "GluePassRolePolicy"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "${aws_iam_role.glue_role.arn}"
      }
    ]
  }
  EOF
}

# Anexando a política ao IAM Role do Glue
resource "aws_iam_role_policy_attachment" "glue_pass_role_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_pass_role_policy.arn
}
