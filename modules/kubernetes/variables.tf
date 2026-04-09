#============================================
# Global Variables
#============================================
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (Homologação, Produção, etc)"
  type        = string
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}

#============================================
# RDS Variables
#============================================
variable "rds_username" {
  type        = string
  description = "Username to RDS Postgres"
}

variable "rds_password" {
  type        = string
  description = "Password to RDS Postgres"
}

variable "db_auth_endpoint" {
  type        = string
  description = "Host endpoint to RDS Postgres"
}

variable "db_flag_endpoint" {
  type        = string
  description = "Host endpoint to RDS Postgres"
}


variable "db_targeting_endpoint" {
  type        = string
  description = "Host endpoint to RDS Postgres"
}

#============================================
# Elasticache Redis Variables
#============================================
variable "evaluation_db_endpoint" {
  type        = string
  description = "ElastiCache/Redis endpoint"
}

#============================================
# SQS Variables
#============================================
variable "sqs_queue_url" {
  type        = string
  description = "SQS Queue"
}

#============================================
# DynamoDB Variables
#============================================
variable "dynamodb_table_name" {
  type        = string
  description = "Dynamodb url"
}