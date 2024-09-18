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

# Criação da Tabela no Glue com Dados em formato Parquet
resource "aws_glue_catalog_table" "career_path_table" {
  name          = "career_path_table"
  database_name = aws_glue_catalog_database.career_path_db.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.career_path.bucket}/data/"  # Diretório no S3 que contém arquivos Parquet
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    compressed    = false  # Ajustar para 'true' se o arquivo Parquet estiver comprimido

    # Definição das colunas do Parquet
    columns {
      name = "title"
      type = "string"
    }

    columns {
      name = "experience"
      type = "string"
    }

    ser_de_info {
      name = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }
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
