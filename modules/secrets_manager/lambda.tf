# Deploya a Lambda de rotação direto do Serverless Application Repository
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rds_rotation" {
  name             = "${var.project_name}-${var.environment}-rds-rotation"
  application_id   = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  semantic_version = "1.1.367"

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]

  parameters = {
    functionName     = "${var.project_name}-${var.environment}-rds-rotation"
    endpoint         = "https://secretsmanager.${var.aws_region}.amazonaws.com"
    vpcSubnetIds     = join(",", var.private_subnet_ids)
    vpcSecurityGroupIds = var.rds_security_group_id
  }
}