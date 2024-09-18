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

# Criação da Tabela no Glue com Dados Não-Aninhados
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
