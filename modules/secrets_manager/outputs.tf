#============================================
# Secrets Manager Outputs
#============================================

output "secret_arns" {
  description = "Map of app name to Secrets Manager secret ARN"
  value       = { for k, v in aws_secretsmanager_secret.app_db_secrets : k => v.arn }
}

output "secret_names" {
  description = "Map of app name to Secrets Manager secret name"
  value       = { for k, v in aws_secretsmanager_secret.app_db_secrets : k => v.name }
}

output "app_passwords" {
  description = "Map of app name to generated password"
  value       = { for k, v in random_password.app_passwords : k => v.result }
  sensitive   = true
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
