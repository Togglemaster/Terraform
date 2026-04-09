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
