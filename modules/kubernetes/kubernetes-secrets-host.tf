#============================================
# Data sources
#============================================
data "aws_region" "current" {}

#============================================
# Adding kubernetes secret host url endpoint - Auth-Service
#============================================
resource "kubernetes_secret_v1" "auth_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.services
  ]

  metadata {
    name      = "auth-service-db-secret-host"
    namespace = "auth-service"
  }

  #Postgres connection string for auth-service
  data = {
    DATABASE_URL = "postgres://${var.rds_username}:${var.rds_password}@${var.db_auth_endpoint}/auth_db?sslmode=require"
  }

  type = "Opaque"
}

#============================================
# Adding kubernetes secret host url endpoint - Flag-Service
#============================================
resource "kubernetes_secret_v1" "flag_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.services
  ]

  metadata {
    name      = "flag-service-db-secret-host"
    namespace = "flag-service"
  }

  #Postgres connection string for flag-service
  data = {
    DATABASE_URL = "postgres://${var.rds_username}:${var.rds_password}@${var.db_auth_endpoint}/flag_db?sslmode=require"
  }

  type = "Opaque"
}

#============================================
# Adding kubernetes secret host url endpoint - Targeting-Service
#============================================
resource "kubernetes_secret_v1" "targeting_db_secret_host" {
  depends_on = [
    kubernetes_namespace_v1.services
  ]

  metadata {
    name      = "targeting-service-db-secret-host"
    namespace = "targeting-service"
  }

  #Postgres connection string for targeting-service
  data = {
    DATABASE_URL = "postgres://${var.rds_username}:${var.rds_password}@${var.db_targeting_endpoint}/targeting_db?sslmode=require"
  }

  type = "Opaque"
}

#============================================
# Adding kubernetes secret host url endpoint - Evaluation-Service
#============================================
resource "kubernetes_secret_v1" "evaluation_db_endpoint" {
  depends_on = [
    kubernetes_namespace_v1.services
  ]

  metadata {
    name      = "evaluation-service-db-secret-host"
    namespace = "evaluation-service"
  }

  #Redis and AWS configuration for evaluation-service
  data = {
    REDIS_URL   = "redis://${var.evaluation_db_endpoint}:6379"
    AWS_REGION  = data.aws_region.current.id
    AWS_SQS_URL = var.sqs_queue_url
  }

  type = "Opaque"
}

#============================================
# Adding kubernetes secret host url endpoint - Analytics-Service
#============================================
resource "kubernetes_secret_v1" "analytics_db_endpoint" {
  depends_on = [
    kubernetes_namespace_v1.services
  ]

  metadata {
    name      = "analytics-service-db-secret-host"
    namespace = "analytics-service"
  }

  #AWS configuration for analytics-service
  data = {
    AWS_DYNAMODB_TABLE = var.dynamodb_table_name
    AWS_REGION         = data.aws_region.current.id
    AWS_SQS_URL        = var.sqs_queue_url
  }

  type = "Opaque"
}