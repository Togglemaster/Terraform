#============================================
# Kubernetes Namespaces Variables
#============================================
variable "namespaces_k8s" {
  description = "namespaces Kubernetes"
  type        = set(string)
  default     = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ]
}

#============================================
# Namespaces Creation
#============================================
resource "kubernetes_namespace_v1" "services" {
  for_each = var.namespaces_k8s

  metadata {
    name = each.value #The name comes from the list above
  }
}