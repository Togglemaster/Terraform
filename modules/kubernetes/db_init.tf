#============================================
# Database Init Jobs
#============================================
# Cria os databases por serviço (auth_db, flag_db, targeting_db) dentro
# do Postgres compartilhado e aplica as migrations iniciais.
# Idempotente: usa CREATE DATABASE/TABLE IF NOT EXISTS.
#============================================

locals {
  db_init_services = toset([
    "auth-service",
    "flag-service",
    "targeting-service",
  ])
}

#============================================
# ConfigMap com o SQL de migration por serviço
#============================================
resource "kubectl_manifest" "db_init_configmap" {
  for_each = local.db_init_services

  depends_on = [kubernetes_namespace_v1.services]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "${each.key}-db-init-sql"
      namespace = each.key
    }
    data = {
      "init.sql" = file("${path.module}/sql/${replace(each.key, "-service", "")}.sql")
    }
  })
}

#============================================
# Job que cria o database e roda a migration
#============================================
resource "kubectl_manifest" "db_init_job" {
  for_each = local.db_init_services

  depends_on = [
    kubernetes_namespace_v1.services,
    kubectl_manifest.external_secrets,
    kubectl_manifest.db_init_configmap,
  ]

  yaml_body = yamlencode({
    apiVersion = "batch/v1"
    kind       = "Job"
    metadata = {
      name      = "${each.key}-db-init"
      namespace = each.key
    }
    spec = {
      backoffLimit            = 6
      ttlSecondsAfterFinished = 300
      template = {
        spec = {
          restartPolicy = "OnFailure"
          containers = [{
            name  = "psql"
            image = "postgres:15"
            env = [{
              name  = "POSTGRES_DB"
              value = replace(each.key, "-service", "_db")
            }]
            envFrom = [{
              secretRef = {
                name = "${each.key}-db-credentials"
              }
            }]
            command = ["sh", "-c"]
            args = [
              <<-EOT
              set -e
              export PGPASSWORD="$POSTGRES_PASSWORD"

              echo "Ensuring database $POSTGRES_DB exists..."
              psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d postgres \
                -tAc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1 \
                || psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d postgres \
                     -c "CREATE DATABASE $POSTGRES_DB"

              echo "Running migrations on $POSTGRES_DB..."
              psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
                   -v ON_ERROR_STOP=1 -f /sql/init.sql

              echo "Done."
              EOT
            ]
            volumeMounts = [{
              name      = "init-sql"
              mountPath = "/sql"
            }]
          }]
          volumes = [{
            name = "init-sql"
            configMap = {
              name = "${each.key}-db-init-sql"
            }
          }]
        }
      }
    }
  })
}
