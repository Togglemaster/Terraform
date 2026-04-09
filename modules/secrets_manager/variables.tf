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

variable "tags" {
  type        = map(any)
  description = "Tags for resources"
}

#============================================
# Secrets Manager Variables
#============================================

variable "app_names" {
  description = "App names"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS security group ID"
  type        = string
}