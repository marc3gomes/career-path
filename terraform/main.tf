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
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.career_path_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.career_path.bucket}/data/"
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping": {
      "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
  })

  schedule = "cron(0 12 * * ? *)"  # Opcional: rodar diariamente ao meio-dia
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

# Política inline do IAM Role para o Athena acessar o S3
resource "aws_iam_role_policy" "athena_s3_policy" {
  name = "AthenaS3AccessPolicy"
  role = aws_iam_role.athena_role.id

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

# Política inline para permitir que o Glue Crawler acesse e atualize o Glue Data Catalog
resource "aws_iam_role_policy" "glue_crawler_policy" {
  name = "GlueCrawlerPolicy"
  role = aws_iam_role.glue_role.id

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

# Criação do IAM Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execute-athena-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Política inline do IAM Role da Lambda para acessar o Athena e o S3
resource "aws_iam_role_policy" "lambda_policy" {
  name = "LambdaAthenaS3AccessPolicy"
  role = aws_iam_role.lambda_role.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "s3:GetObject",
          "s3:ListBucket",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}


# Criação da função Lambda em Python
resource "aws_lambda_function" "athena_query_function" {
  function_name = "athena-query-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"   # handler no formato Python: arquivo.funcao
  runtime       = "python3.9"                 # Definindo Python como runtime
  timeout       = 10

  # Código da Lambda que consulta o Athenaa
  source_code_hash = filebase64sha256("../lambda_function.zip")

  filename = "../lambda_function.zip"  # O arquivo zip que contém lambda_function.py

  environment {
    variables = {
      ATHENA_DATABASE = aws_glue_catalog_database.career_path_db.name
      ATHENA_OUTPUT   = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }
  }
}


# Criação da permissão para a Lambda ser executada por API Gateway
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.athena_query_function.function_name
  principal     = "apigateway.amazonaws.com"
}


#Criação do API Gateway REST API
resource "aws_api_gateway_rest_api" "athena_api" {
  name        = "athena-query-api"
  description = "API Gateway para consultar dados via Lambda no Athena"
}

# Criação do recurso para o método de requisição HTTP
resource "aws_api_gateway_resource" "athena_query_resource" {
  rest_api_id = aws_api_gateway_rest_api.athena_api.id
  parent_id   = aws_api_gateway_rest_api.athena_api.root_resource_id
  path_part   = "query"  # Define o caminho /query na URL
}

# Definir o método HTTP (POST) para a função Lambda
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.athena_api.id
  resource_id   = aws_api_gateway_resource.athena_query_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integração do método com a Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.athena_api.id
  resource_id = aws_api_gateway_resource.athena_query_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.athena_query_function.invoke_arn
}

# Criação do método de resposta
resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = aws_api_gateway_rest_api.athena_api.id
  resource_id = aws_api_gateway_resource.athena_query_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

# Integração da resposta
resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.athena_api.id
  resource_id = aws_api_gateway_resource.athena_query_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.method_response.status_code
}

# Criação do deployment da API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.athena_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method_response.method_response
  ]
}