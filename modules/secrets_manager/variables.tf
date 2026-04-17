# =============================================================================
# VARIÁVEIS GLOBAIS
# =============================================================================

variable "aws_region" {
  type        = string
  description = "AWS region (usado no endpoint da Lambda de rotação)"
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

variable "rds_db_name" {
  type        = string
  description = "Nome do banco de dados no RDS"
}

variable "rds_username" {
  type        = string
  description = "Usuário do banco de dados (mesmo para todos os serviços)"
}

# =============================================================================
# REDE (necessária apenas para a Lambda de rotação)
# =============================================================================

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets privadas onde a Lambda de rotação será executada"
}

variable "rds_security_group_id" {
  type        = string
  description = "ID do security group do RDS (atribuído à Lambda de rotação)"
}

# =============================================================================
# CONFIGURAÇÃO DOS SECRETS
# =============================================================================

variable "app_names" {
  type        = list(string)
  description = "Serviços que receberão secrets de banco de dados"
  default     = ["auth-service", "flag-service", "targeting-service"]
}

variable "enable_rotation" {
  type        = bool
  description = "Habilita rotação automática de senhas via Lambda"
  default     = false
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
