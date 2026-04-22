output "eso_namespace" {
  description = "Namespace onde o External Secrets Operator foi instalado"
  value       = helm_release.external_secrets.namespace
}

output "eso_service_account_name" {
  description = "Nome do ServiceAccount do ESO (para referenciar em ClusterSecretStore)"
  value       = var.eso_service_account_name
}

output "eso_release_name" {
  description = "Nome do release Helm do ESO"
  value       = helm_release.external_secrets.name
}

output "alb_controller_role_arn" {
  description = "ARN da role IRSA do AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_release_name" {
  description = "Nome do release Helm do ALB Controller"
  value       = helm_release.alb_controller.name
}

output "metrics_server_release_name" {
  description = "Nome do release Helm do Metrics Server"
  value       = helm_release.metrics_server.name
}
