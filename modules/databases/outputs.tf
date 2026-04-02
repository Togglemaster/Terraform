#============================================
# RDS Outputs
#============================================
output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.db.db_instance_resource_id
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
