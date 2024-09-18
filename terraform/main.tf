# Criação do Bucket S3 para armazenar os dados Parquet
resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"
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

# Política do bucket S3 para permitir que o Athena grave os resultados no S3
resource "aws_s3_bucket_policy" "athena_results_policy" {
  bucket = aws_s3_bucket.athena_results.bucket

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "athena.amazonaws.com"
        },
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.athena_results.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.athena_results.bucket}/*"
        ]
      }
    ]
  }
  EOF
}


# Política do bucket S3 para permitir acesso ao Glue e Athena
resource "aws_s3_bucket_policy" "career_path_policy" {
  bucket = aws_s3_bucket.career_path.bucket

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "athena.amazonaws.com",
            "glue.amazonaws.com"
          ]
        },
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

# Criação do Glue Database
resource "aws_glue_catalog_database" "career_path_db" {
  name = "career_path_db"
}

# Criação do Glue Crawler para detectar automaticamente o esquema e criar a tabela
resource "aws_glue_crawler" "career_path_crawler" {
  name          = "career-path-crawler"
  role          = aws_iam_role.glue_role.arn  # O Role do Glue
  database_name = aws_glue_catalog_database.career_path_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.career_path.bucket}/data/"  # Caminho S3 onde os arquivos Parquet estão
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping": {
      "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
  })

  schedule = "cron(0 12 * * ? *)"  # Opcional: rodar diariamente ao meio-dia

  depends_on = [
    aws_iam_role_policy_attachment.glue_s3_policy_attach
  ]
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

# Política do IAM Role para acesso ao S3
resource "aws_iam_policy" "glue_s3_policy" {
  name = "GlueS3AccessPolicy"

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

# Anexando a política ao IAM Role do Glue
resource "aws_iam_role_policy_attachment" "glue_s3_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

# Criação do IAM Role para o Athena
resource "aws_iam_role" "athena_role" {
  name = "athena-service-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "athena.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Política do IAM Role para acesso ao S3 para o Athena
resource "aws_iam_policy" "athena_s3_policy" {
  name = "AthenaS3AccessPolicy"

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

# Anexando a política ao IAM Role do Athena
resource "aws_iam_role_policy_attachment" "athena_s3_policy_attach" {
  role       = aws_iam_role.athena_role.name
  policy_arn = aws_iam_policy.athena_s3_policy.arn
}

# Política para permitir que o Glue Crawler acesse e atualize o Glue Data Catalog
resource "aws_iam_policy" "glue_crawler_policy" {
  name = "GlueCrawlerPolicy"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "glue:GetTable",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetDatabase",
          "glue:CreateDatabase",
          "glue:UpdateDatabase"
        ],
        "Resource": [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/${aws_glue_catalog_database.career_path_db.name}",
          "arn:aws:glue:*:*:table/${aws_glue_catalog_database.career_path_db.name}/*"
        ]
      }
    ]
  }
  EOF
}

# Anexando a política ao IAM Role do Glue
resource "aws_iam_role_policy_attachment" "glue_crawler_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}
