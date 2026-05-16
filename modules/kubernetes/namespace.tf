#============================================
# Kubernetes Namespaces Variables
#============================================
# OBS: argocd NAO entra aqui. O namespace argocd e criado pelo pipeline
# (`helm upgrade --install argocd ... --create-namespace` em
# togglemaster/.github/workflows/helm_deploy.yaml). Quando o cluster EKS
# for destruido, o namespace vai junto. Manter argocd fora do Terraform
# evita o classico "namespace travado em Terminating" no destroy.
#============================================
variable "namespaces_k8s" {
  description = "namespaces Kubernetes gerenciados pelo Terraform (servicos da app)"
  type        = set(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
  ]
}

#============================================
# Namespaces Creation
#============================================
resource "kubernetes_namespace_v1" "services" {
  for_each = var.namespaces_k8s

  metadata {
    name = each.value
    labels = {
      "admission.datadoghq.com/enabled" = "true"
    }
  }
}
