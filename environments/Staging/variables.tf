# =============================================================================
# VARIÁVEIS GLOBAIS DO PROJETO
# =============================================================================
variable "aws_region" {
  type        = string
  description = "AWS Region for resources deployment"
}

variable "project_name" {
  type        = string
  description = "Project name to identify resources"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for VPC"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "654654467270"
}

variable "tags" {
  type        = map(any)
  description = "Tags for resources"
}

# =============================================================================
# VARIÁVEIS DO MÓDULO EKS-CLUSTER
# =============================================================================
variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

# =============================================================================
# VARIÁVEIS DO MÓDULO DATABASES
# =============================================================================
variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "togglemaster"
}

variable "rds_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "ECR repository names"
  type        = list(string)
  default     = [
    "auth-service",
    "flag-service", 
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ]
}

# =============================================================================
# VARIÁVEIS DO MÓDULO KUBERNETES
# =============================================================================
variable "sqs_queue_url" {
  description = "SQS queue URL for analytics"
  type        = string
}

variable "db_auth_endpoint" {
  description = "Auth service endpoint"
  type        = string
}

variable "db_flag_endpoint" {
  description = "Flag service endpoint"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for analytics"
  type        = string
}

variable "db_targeting_endpoint" {
  description = "Targeting service database endpoint"
  type        = string
}

variable "evaluation_db_endpoint" {
  description = "Evaluation service database endpoint"
  type        = string
}