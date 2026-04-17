# ============================================================
# Geração de senhas aleatórias para cada serviço
# ============================================================

resource "random_password" "app_passwords" {
  for_each = toset(var.app_names)

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================================
# Secrets Manager - um secret por serviço
# ============================================================

resource "aws_secretsmanager_secret" "app_db_secrets" {
  for_each = toset(var.app_names)

  name                    = "${var.project_name}/${var.environment}/${each.key}/db-credentials"
  description             = "Credenciais do banco de dados para o serviço ${each.key}"
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Service = each.key
  })
}

resource "aws_secretsmanager_secret_version" "app_db_secrets" {
  for_each = toset(var.app_names)

  secret_id = aws_secretsmanager_secret.app_db_secrets[each.key].id

  secret_string = jsonencode({
    engine   = "postgres"
    host     = var.rds_address
    port     = var.rds_port
    dbname   = var.rds_db_name
    username = var.rds_username
    password = random_password.app_passwords[each.key].result
  })
}

# ============================================================
# Evaluation service — Redis + SQS + Region
# ============================================================

resource "aws_secretsmanager_secret" "evaluation_config" {
  name                    = "${var.project_name}/${var.environment}/evaluation-service/config"
  description             = "Variáveis de infraestrutura do evaluation-service"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "evaluation-service" })
}

resource "aws_secretsmanager_secret_version" "evaluation_config" {
  secret_id = aws_secretsmanager_secret.evaluation_config.id

  secret_string = jsonencode({
    REDIS_URL   = var.redis_url
    AWS_SQS_URL = var.sqs_url
    AWS_REGION  = var.aws_region
  })
}

# ============================================================
# Analytics service — AWS credentials
# ============================================================

resource "aws_secretsmanager_secret" "analytics_config" {
  name                    = "${var.project_name}/${var.environment}/analytics-service/config"
  description             = "Credenciais AWS do analytics-service"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "analytics-service" })
}

resource "aws_secretsmanager_secret_version" "analytics_config" {
  secret_id = aws_secretsmanager_secret.analytics_config.id

  secret_string = jsonencode({
    AWS_REGION          = var.aws_region
    AWS_SQS_URL         = var.sqs_url
    AWS_DYNAMODB_TABLE  = var.dynamodb_table_name
  })
}

# ============================================================
# Evaluation service — URLs (preenchidos via pipeline)
# ============================================================

resource "aws_secretsmanager_secret" "evaluation_urls" {
  name                    = "${var.project_name}/${var.environment}/evaluation-service/urls"
  description             = "URLs de serviços dependentes do evaluation-service (preenchido via pipeline)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "evaluation-service" })
}

# ============================================================
# Analytics service — AWS credentials (preenchidos via pipeline)
# ============================================================

resource "aws_secretsmanager_secret" "analytics_credentials" {
  name                    = "${var.project_name}/${var.environment}/analytics-service/credentials"
  description             = "Credenciais AWS do analytics-service (preenchido via pipeline)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "analytics-service" })
}

# ============================================================
# Auth service — master key (preenchido via pipeline)
# ============================================================

resource "aws_secretsmanager_secret" "auth_config" {
  name                    = "${var.project_name}/${var.environment}/auth-service/config"
  description             = "Configurações do auth-service (preenchido via pipeline)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "auth-service" })
}

# ============================================================
# Flag service — URLs de dependências (preenchido via pipeline)
# ============================================================

resource "aws_secretsmanager_secret" "flag_config" {
  name                    = "${var.project_name}/${var.environment}/flag-service/config"
  description             = "Configurações do flag-service (preenchido via pipeline)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "flag-service" })
}

# ============================================================
# Rotação automática (opcional — requer enable_rotation = true)
# ============================================================

resource "aws_secretsmanager_secret_rotation" "app_db_secrets" {
  for_each = var.enable_rotation ? toset(var.app_names) : toset([])

  secret_id           = aws_secretsmanager_secret.app_db_secrets[each.key].id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rds_rotation[0].outputs["LambdaFunctionArn"]

  rotation_rules {
    automatically_after_days = 30
  }

  depends_on = [aws_secretsmanager_secret_version.app_db_secrets]
}
