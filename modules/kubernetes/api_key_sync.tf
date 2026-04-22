#============================================
# API Key Sync Job
#============================================
# Espera o auth-service ficar disponível, gera uma API key via endpoint
# admin usando MASTER_KEY, e injeta como Secret `shared-api-key` no
# namespace do evaluation-service. Depois reinicia o Deployment do
# evaluation-service para carregar a nova key.
#
# A espera é infinita (loop com retry) — o Job não tem activeDeadlineSeconds.
#============================================

#============================================
# ServiceAccount com permissão de manipular Secrets e Deployments cross-namespace
#============================================
resource "kubectl_manifest" "sync_key_service_account" {
  depends_on = [kubernetes_namespace_v1.services]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "key-manager"
      namespace = "auth-service"
    }
  })
}

resource "kubectl_manifest" "sync_key_cluster_role" {
  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "job-cross-namespace-role"
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["secrets"]
        verbs     = ["get", "create", "patch", "update", "list"]
      },
      {
        apiGroups = ["apps"]
        resources = ["deployments"]
        verbs     = ["get", "patch", "list", "update", "watch"]
      },
    ]
  })
}

resource "kubectl_manifest" "sync_key_cluster_role_binding" {
  depends_on = [
    kubectl_manifest.sync_key_service_account,
    kubectl_manifest.sync_key_cluster_role,
  ]

  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "job-orchestrator-global-binding"
    }
    subjects = [{
      kind      = "ServiceAccount"
      name      = "key-manager"
      namespace = "auth-service"
    }]
    roleRef = {
      kind     = "ClusterRole"
      name     = "job-cross-namespace-role"
      apiGroup = "rbac.authorization.k8s.io"
    }
  })
}

#============================================
# Job de sincronização
#============================================
resource "kubectl_manifest" "sync_key_job" {
  depends_on = [
    kubernetes_namespace_v1.services,
    kubectl_manifest.external_secrets,
    kubectl_manifest.sync_key_cluster_role_binding,
  ]

  yaml_body = yamlencode({
    apiVersion = "batch/v1"
    kind       = "Job"
    metadata = {
      name      = "sync-key"
      namespace = "auth-service"
    }
    spec = {
      backoffLimit            = 30
      ttlSecondsAfterFinished = 300
      template = {
        spec = {
          serviceAccountName = "key-manager"
          restartPolicy      = "OnFailure"
          containers = [{
            name  = "orchestrator"
            image = "bitnami/kubectl:1.32"
            env = [{
              name = "ADMIN_TOKEN"
              valueFrom = {
                secretKeyRef = {
                  name = "auth-service-config"
                  key  = "MASTER_KEY"
                }
              }
            }]
            command = ["/bin/bash", "-c"]
            args = [
              <<-EOT
              set -e

              echo "Aguardando deployment app-auth-service ficar disponível..."
              until kubectl wait --for=condition=available --timeout=30s \
                    deployment/app-auth-service -n auth-service >/dev/null 2>&1; do
                echo "  ...ainda não está pronto, nova tentativa em 15s"
                sleep 15
              done
              echo "Deployment app-auth-service disponível!"

              echo "Gerando nova chave no Auth Service..."
              RESPONSE=$(curl -sS -X POST http://app-auth-service.auth-service.svc.cluster.local:8001/admin/keys \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $ADMIN_TOKEN" \
                -d '{"name": "admin-para-flag-service"}')
              echo "Resposta: $RESPONSE"

              if [ -z "$RESPONSE" ]; then
                echo "Erro: resposta vazia do auth-service"
                exit 1
              fi

              VALOR_PURO=$(echo "$RESPONSE" | sed -n 's/.*"key":"\([^"]*\)".*/\1/p')
              if [ -z "$VALOR_PURO" ]; then
                echo "Erro: não foi possível extrair a chave da resposta"
                exit 1
              fi
              echo "API-KEY gerada com sucesso"

              echo "Injetando secret shared-api-key no namespace evaluation-service..."
              kubectl create secret generic shared-api-key \
                --from-literal=SERVICE_API_KEY="$VALOR_PURO" \
                --namespace evaluation-service \
                --dry-run=client -o yaml | kubectl apply -f -

              echo "Reiniciando deployment app-evaluation-service..."
              kubectl rollout restart deployment app-evaluation-service -n evaluation-service

              echo "Processo finalizado com sucesso!"
              EOT
            ]
          }]
        }
      }
    }
  })
}
