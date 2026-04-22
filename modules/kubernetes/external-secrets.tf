#============================================
# External Secrets Operator — mapeamento AWS ↔ Namespace
#============================================
# Usa kubectl_manifest (não valida CRD no plan), permitindo single-apply
# junto com o helm_release do ESO (módulo helm).
#============================================

data "aws_region" "current" {}

locals {
  secret_prefix = "${var.project_name}/${var.environment}"

  # Mapa lógico → { namespace, aws_key, target_secret }
  # Adicione entradas aqui para criar novos mapeamentos.
  external_secrets = {
    auth_db = {
      namespace     = "auth-service"
      aws_key       = "auth-service/db-credentials"
      target_secret = "auth-service-db-credentials"
    }
    auth_config = {
      namespace     = "auth-service"
      aws_key       = "auth-service/config"
      target_secret = "auth-service-config"
    }
    flag_db = {
      namespace     = "flag-service"
      aws_key       = "flag-service/db-credentials"
      target_secret = "flag-service-db-credentials"
    }
    flag_config = {
      namespace     = "flag-service"
      aws_key       = "flag-service/config"
      target_secret = "flag-service-config"
    }
    targeting_db = {
      namespace     = "targeting-service"
      aws_key       = "targeting-service/db-credentials"
      target_secret = "targeting-service-db-credentials"
    }
    targeting_config = {
      namespace     = "targeting-service"
      aws_key       = "targeting-service/config"
      target_secret = "targeting-service-config"
    }
    evaluation_config = {
      namespace     = "evaluation-service"
      aws_key       = "evaluation-service/config"
      target_secret = "evaluation-service-config"
    }
    evaluation_urls = {
      namespace     = "evaluation-service"
      aws_key       = "evaluation-service/urls"
      target_secret = "evaluation-service-urls"
    }
    analytics_config = {
      namespace     = "analytics-service"
      aws_key       = "analytics-service/config"
      target_secret = "analytics-service-config"
    }
    analytics_credentials = {
      namespace     = "analytics-service"
      aws_key       = "analytics-service/credentials"
      target_secret = "analytics-service-credentials"
    }
  }
}

#============================================
# ClusterSecretStore — único para todos os namespaces
#============================================
resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.id
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = var.eso_service_account_name
                namespace = var.eso_service_account_namespace
              }
            }
          }
        }
      }
    }
  })
}

#============================================
# ExternalSecrets — um por par (AWS secret × namespace)
#============================================
resource "kubectl_manifest" "external_secrets" {
  for_each = local.external_secrets

  depends_on = [
    kubernetes_namespace_v1.services,
    kubectl_manifest.cluster_secret_store,
  ]

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.value.target_secret
      namespace = each.value.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "aws-secrets"
      }
      target = {
        name           = each.value.target_secret
        creationPolicy = "Owner"
      }
      dataFrom = [{
        extract = {
          key = "${local.secret_prefix}/${each.value.aws_key}"
        }
      }]
    }
  })
}
