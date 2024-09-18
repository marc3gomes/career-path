# Criação do Bucket S3
resource "aws_s3_bucket" "career_path" {
  bucket = "career-path-terraform-studies"
  force_destroy = true

  tags = {
    Name        = "Career Path Data Bucket"
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
