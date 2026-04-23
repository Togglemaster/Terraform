#============================================
# External Secrets Operator (ESO)
#============================================
# Instala o chart oficial e cria o ServiceAccount já anotado
# com o ARN da role IRSA (var.eso_role_arn).
#============================================

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_chart_version
  namespace        = var.eso_namespace
  create_namespace = true

  # Instala os CRDs (ClusterSecretStore, ExternalSecret, etc.)
  set {
    name  = "installCRDs"
    value = "true"
  }

  # ServiceAccount anotado para IRSA
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.eso_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.eso_role_arn
  }

  # Espera os pods ficarem prontos antes de considerar o apply concluído.
  # Importante para que módulos dependentes (kubectl_manifest) encontrem os CRDs.
  wait          = true
  wait_for_jobs = true
  timeout       = 600
}
