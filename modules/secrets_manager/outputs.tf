#============================================
# Secrets Manager Outputs
#============================================

output "shared_db_credentials_secret_arn" {
  description = "ARN do secret compartilhado com as credenciais do Postgres"
  value       = aws_secretsmanager_secret.shared_db_credentials.arn
}

output "shared_db_credentials_secret_name" {
  description = "Nome do secret compartilhado com as credenciais do Postgres"
  value       = aws_secretsmanager_secret.shared_db_credentials.name
}

output "evaluation_config_secret_arn" {
  description = "ARN do secret de config do evaluation-service"
  value       = aws_secretsmanager_secret.evaluation_config.arn
}

output "evaluation_urls_secret_arn" {
  description = "ARN do secret de URLs do evaluation-service"
  value       = aws_secretsmanager_secret.evaluation_urls.arn
}

output "analytics_config_secret_arn" {
  description = "ARN do secret de config do analytics-service"
  value       = aws_secretsmanager_secret.analytics_config.arn
}

output "analytics_credentials_secret_arn" {
  description = "ARN do secret de credenciais do analytics-service"
  value       = aws_secretsmanager_secret.analytics_credentials.arn
}

output "auth_config_secret_arn" {
  description = "ARN do secret de config do auth-service"
  value       = aws_secretsmanager_secret.auth_config.arn
}

output "flag_config_secret_arn" {
  description = "ARN do secret de config do flag-service"
  value       = aws_secretsmanager_secret.flag_config.arn
}

output "eso_role_arn" {
  description = "ARN da role IRSA do External Secrets Operator (usar em eks.amazonaws.com/role-arn no ServiceAccount)"
  value       = aws_iam_role.eso.arn
}
