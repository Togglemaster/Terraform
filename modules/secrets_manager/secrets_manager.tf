# ============================================================
# Credencial compartilhada do Postgres
# Lê o secret gerenciado pelo RDS (username/password) e combina
# com host/port/dbname num único secret consumido por todos os
# serviços que falam com o Postgres.
# ============================================================

data "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = var.rds_master_user_secret_arn
}

locals {
  rds_master = jsondecode(data.aws_secretsmanager_secret_version.rds_master.secret_string)
}

resource "aws_secretsmanager_secret" "shared_db_credentials" {
  name                    = "${var.project_name}/${var.environment}/shared/db-credentials"
  description             = "Credenciais compartilhadas do Postgres (consumidas por todos os serviços)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "shared" })
}

resource "aws_secretsmanager_secret_version" "shared_db_credentials" {
  secret_id = aws_secretsmanager_secret.shared_db_credentials.id

  secret_string = jsonencode({
    POSTGRES_HOST     = var.rds_address
    POSTGRES_PORT     = var.rds_port
    POSTGRES_USER     = local.rds_master.username
    POSTGRES_PASSWORD = local.rds_master.password
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
    AWS_REGION         = var.aws_region
    AWS_SQS_URL        = var.sqs_url
    AWS_DYNAMODB_TABLE = var.dynamodb_table_name
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
# Targeting service — URLs de dependências (preenchido via pipeline)
# ============================================================

resource "aws_secretsmanager_secret" "targeting_config" {
  name                    = "${var.project_name}/${var.environment}/targeting-service/config"
  description             = "Configurações do targeting-service (preenchido via pipeline)"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Service = "targeting-service" })
}
