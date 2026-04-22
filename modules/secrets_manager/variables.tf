# =============================================================================
# VARIÁVEIS GLOBAIS
# =============================================================================

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto para identificação dos recursos"
}

variable "environment" {
  type        = string
  description = "Nome do ambiente (Production, Staging, etc)"
}

variable "tags" {
  type        = map(string)
  description = "Tags aplicadas aos recursos"
  default     = {}
}

# =============================================================================
# RDS
# =============================================================================

variable "rds_address" {
  type        = string
  description = "Hostname do RDS (sem porta)"
}

variable "rds_port" {
  type        = number
  description = "Porta do RDS"
}

variable "rds_master_user_secret_arn" {
  type        = string
  description = "ARN do secret gerenciado pelo RDS com username/password do master user"
}

# =============================================================================
# EVALUATION SERVICE
# =============================================================================

variable "redis_url" {
  type        = string
  description = "URL de conexão do Redis (ElastiCache)"
}

variable "sqs_url" {
  type        = string
  description = "URL da fila SQS"
}

# =============================================================================
# ANALYTICS SERVICE
# =============================================================================

variable "dynamodb_table_name" {
  type        = string
  description = "Nome da tabela DynamoDB do analytics-service"
}

# =============================================================================
# IRSA — External Secrets Operator
# =============================================================================

variable "oidc_provider_arn" {
  type        = string
  description = "ARN do OIDC provider do cluster EKS (output do módulo eks-cluster)"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL do OIDC provider do cluster EKS (ex: https://oidc.eks.<region>.amazonaws.com/id/XXXX)"
}

variable "eso_service_account_name" {
  type        = string
  description = "Nome do ServiceAccount usado pelo External Secrets Operator"
  default     = "external-secrets"
}

variable "eso_service_account_namespace" {
  type        = string
  description = "Namespace onde o ServiceAccount do ESO vive"
  default     = "external-secrets"
}
