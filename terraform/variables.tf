variable "bucket_name" {
  description = "Nome do bucket S3"
  default     = "career-path-terraform-studies"
}

variable "glue_database_name" {
  description = "Nome do Glue Database"
  default     = "career_path_db"
}

variable "glue_table_name" {
  description = "Nome da Tabela no Glue"
  default     = "career_path_table"
}
