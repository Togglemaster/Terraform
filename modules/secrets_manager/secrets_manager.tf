# ============================================================
# Geração de senhas aleatórias temporárias para cada app (auth - flag - targeting)
# ============================================================

resource "random_password" "app_passwords" {
  for_each = toset(var.app_names)

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================================
# Secrets Manager - um secret por app
# ============================================================

resource "aws_secretsmanager_secret" "app_db_secrets" {
  for_each = toset(var.app_names)

  name        = "${var.project_name}/${var.environment}/${each.key}/db-credentials"
  description = "Credenciais do banco de dados para a app ${each.key}"


  # "Dias para recuperação do secret após deleção (0 = deleção imediata)"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    App = each.key
  })
}

resource "aws_secretsmanager_secret_version" "app_db_secrets" {
  for_each = toset(var.app_names)

  secret_id = aws_secretsmanager_secret.app_db_secrets[each.key].id

  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
    username = "${each.key}_user"
    password = random_password.app_passwords[each.key].result
  })

  # Recria o secret se a instância RDS mudar
  depends_on = [aws_db_instance.main]
}

# ============================================================
# Rotation automática
# ============================================================

resource "aws_secretsmanager_secret_rotation" "app_db_secrets" {
  for_each = false ? toset(var.app_names) : toset([])

  secret_id           = aws_secretsmanager_secret.app_db_secrets[each.key].id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rds_rotation.outputs["LambdaFunctionArn"]

  # Intervalo em dias para rotação automática
  rotation_rules {
    automatically_after_days = 30
  }

  depends_on = [aws_secretsmanager_secret_version.app_db_secrets]
}