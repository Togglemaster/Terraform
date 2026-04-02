#============================================
# DynamoDB Module
#============================================
module "dynamodb_table" {
  #External module - community module for DynamoDB
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.1.0"

  name     = "${var.project_name}-dynamodb-${var.environment}"
  hash_key = "event_id"

  attributes = [
    {
      name = "event_id"
      type = "S"
    }
  ]

  #Additional configurations
  #Point in time recovery enabled
  point_in_time_recovery_enabled = true
  #Encryption
  server_side_encryption_enabled = true

  #Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}_dynamodb"
    }
  )
}