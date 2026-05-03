#============================================
# RDS Outputs
#============================================
output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds_postgres.db_instance_resource_id
}

output "rds_instance_address" {
  description = "RDS instance hostname"
  value       = module.rds_postgres.db_instance_address
}

output "rds_instance_port" {
  description = "RDS instance port"
  value       = module.rds_postgres.db_instance_port
}

output "rds_db_name" {
  description = "RDS database name"
  value       = module.rds_postgres.db_instance_name
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_security_group.id
}

output "rds_master_user_secret_arn" {
  description = "ARN do secret com username/password do master user do RDS (gerado via Terraform com chars URL-safe)"
  value       = aws_secretsmanager_secret.rds_master.arn
}

output "rds_username" {
  description = "Username do master user do RDS"
  value       = var.rds_username
}

output "rds_password" {
  description = "Password do master user do RDS (gerado via random_password)"
  value       = random_password.rds_master.result
  sensitive   = true
}

#============================================
# DynamoDB Outputs
#============================================
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb_table.dynamodb_table_id
}

#============================================
# ElastiCache Outputs
#============================================
output "elasticache_endpoint" {
  value = module.elasticache.replication_group_primary_endpoint_address
}