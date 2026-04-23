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

output "nginx_ingress_release_name" {
  description = "Nome do release Helm do NGINX Ingress Controller"
  value       = helm_release.nginx_ingress.name
}

output "nginx_ingress_namespace" {
  description = "Namespace onde o NGINX Ingress Controller está instalado"
  value       = helm_release.nginx_ingress.namespace
}

output "metrics_server_release_name" {
  description = "Nome do release Helm do Metrics Server"
  value       = helm_release.metrics_server.name
}
