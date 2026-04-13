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
# VARIÁVEIS DO MÓDULO DATABASES
# =============================================================================
variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "togglemaster"
}

variable "repository_name" {
  description = "ECR repository names"
  type        = list(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ]
}

