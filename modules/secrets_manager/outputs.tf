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
