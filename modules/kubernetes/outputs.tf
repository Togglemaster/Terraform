#============================================
# Kubernetes Namespace Outputs
#============================================

output "namespaces" {
  description = "Map de todas as namespaces criadas"
  value       = { for k, v in kubernetes_namespace_v1.services : k => v.metadata[0].name }
}

output "namespace_auth" {
  description = "Namespace do auth-service"
  value       = kubernetes_namespace_v1.services["auth-service"].metadata[0].name
}

output "namespace_flag" {
  description = "Namespace do flag-service"
  value       = kubernetes_namespace_v1.services["flag-service"].metadata[0].name
}

output "namespace_targeting" {
  description = "Namespace do targeting-service"
  value       = kubernetes_namespace_v1.services["targeting-service"].metadata[0].name
}

output "namespace_evaluation" {
  description = "Namespace do evaluation-service"
  value       = kubernetes_namespace_v1.services["evaluation-service"].metadata[0].name
}

output "namespace_analytics" {
  description = "Namespace do analytics-service"
  value       = kubernetes_namespace_v1.services["analytics-service"].metadata[0].name
}
