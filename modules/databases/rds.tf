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
# RDS Module
#============================================
module "rds_postgres" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-rds-${var.environment}"

  engine            = "postgres"
  engine_version    = "15.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "togglemaster_${var.environment}"
  username = "togglemaster_admin"
  password = var.rds_password
  port     = 5432

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
  skip_final_snapshot = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds"
    }
  )
}