#============================================
# SQS Module
#============================================
module "sqs" {
  #External module - community module for SQS
  source  = "terraform-aws-modules/sqs/aws"
  version = "5.2.1"

  #Queue name - standard queue
  name = "${var.project_name}-sqs_queue-${var.environment}"

  #Queue attributes----------
  #The time in seconds that the delivery of all messages in the queue will be delayed
  delay_seconds = 0
  #The limit of how many bytes a message can contain before Amazon SQS rejects it
  max_message_size = 262144
  #The number of seconds Amazon SQS retains a message
  message_retention_seconds = 86400
  #The time in seconds that the policy waits for a message to arrive in the queue before returning the request
  receive_wait_time_seconds = 10
  #The length of time during which a message will be unavailable after a message is delivered from the queue
  visibility_timeout_seconds = 60

  #Encryption
  sqs_managed_sse_enabled = true

  # DLQ
  create_dlq = true
  dlq_name   = "${var.project_name}_${var.environment}_sqs_dlq"

  #Limit of receives before moving to DLQ
  redrive_policy = { maxReceiveCount = 5 }

  dlq_message_retention_seconds = 86400

  #Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}_${var.environment}_sqs"
    }
  )
}