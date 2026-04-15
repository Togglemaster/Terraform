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
