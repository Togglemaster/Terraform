#============================================
# SQS Outputs
#============================================
output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = module.sqs.queue_url
}

output "sqs_queue_id" {
  description = "SQS queue ID"
  value       = module.sqs.queue_id
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = module.sqs.queue_arn
}