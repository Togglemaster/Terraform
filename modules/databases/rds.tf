#============================================
# RDS Security Group. It will allow all trafic from vpc project
#============================================
resource "aws_security_group" "rds_security_group" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Allow Postgres from inside VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds-sg"
    }
  )
}

#============================================
# Master password — gerada com chars URL-safe apenas
#============================================
# AWS-managed (manage_master_user_password = true) gera senha com qualquer
# printable ASCII (`:`, `?`, `@`, `<`, ...), o que quebra parsers de URL
# `postgres://user:pass@host/db` no app. Geramos aqui usando só chars
# unreserved do RFC 3986 (`-_.~` + alfanuméricos) — vão pra qualquer URL
# sem precisar de percent-encoding.
#============================================
resource "random_password" "rds_master" {
  length           = 32
  special          = true
  override_special = "_-.~"
  upper            = true
  lower            = true
  numeric          = true
}

resource "aws_secretsmanager_secret" "rds_master" {
  name                    = "${var.project_name}/${var.environment}/rds/master"
  description             = "Credenciais do master user do RDS (geradas via Terraform com chars URL-safe)"
  recovery_window_in_days = 0

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds-master-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = aws_secretsmanager_secret.rds_master.id
  secret_string = jsonencode({
    username = var.rds_username
    password = random_password.rds_master.result
  })
}

#============================================
# RDS Module
#============================================
module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = "${var.project_name}-rds-${var.environment}"

  engine            = "postgres"
  engine_version    = "15.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name                     = "togglemaster_${var.environment}"
  username                    = var.rds_username
  password                    = random_password.rds_master.result
  manage_master_user_password = false
  port                        = 5432

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "RDSMonitoringRole-${var.environment}"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.private_subnet_ids

  # DB parameter group
  family = "postgres15"

  # Database Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds"
    }
  )
}