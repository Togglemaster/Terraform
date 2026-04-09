# Outputs do módulo Kubernetes
output "kubernetes_namespaces" {
  description = "Lista das namespaces Kubernetes criadas"
  value       = module.kubernetes.namespaces
}

output "kubernetes_namespace_auth" {
  description = "Namespace auth-service"
  value       = module.kubernetes.namespace_auth
}

output "kubernetes_namespace_flag" {
  description = "Namespace flag-service"
  value       = module.kubernetes.namespace_flag
}

output "kubernetes_namespace_targeting" {
  description = "Namespace targeting-service"
  value       = module.kubernetes.namespace_targeting
}

output "kubernetes_namespace_evaluation" {
  description = "Namespace evaluation-service"
  value       = module.kubernetes.namespace_evaluation
}

output "kubernetes_namespace_analytics" {
  description = "Namespace analytics-service"
  value       = module.kubernetes.namespace_analytics
}
