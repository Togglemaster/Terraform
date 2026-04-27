#============================================
# Kubernetes Namespaces Variables
#============================================
variable "namespaces_k8s" {
  description = "namespaces Kubernetes"
  type        = set(string)
  default = [
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service",
    "argocd"
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

#============================================
# Drain de finalizers do ArgoCD no destroy
#============================================
# O ArgoCD e instalado por fora do Terraform, mas suas CRDs (Application,
# AppProject) usam o finalizer "resources-finalizer.argocd.argoproj.io".
# Quando o cluster esta sendo desmontado, o controller do ArgoCD some
# antes desses finalizers serem processados, e o namespace argocd fica
# preso em Terminating -> destroy do Terraform estoura context deadline.
#
# Este null_resource depende do namespace argocd, entao na ordem de destroy
# ele e processado ANTES da delecao do namespace: limpa os finalizers de
# Applications/AppProjects e, como ultimo recurso, remove o finalizer do
# proprio namespace via API /finalize.
#============================================
resource "null_resource" "argocd_finalizer_drain" {
  triggers = {
    region       = var.aws_region
    cluster_name = var.cluster_name
    namespace    = "argocd"
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set +e
      REGION="${self.triggers.region}"
      CLUSTER="${self.triggers.cluster_name}"
      NS="${self.triggers.namespace}"

      echo ">> Refreshing kubeconfig for $CLUSTER"
      aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER" >/dev/null 2>&1

      if ! kubectl get namespace "$NS" >/dev/null 2>&1; then
        echo ">> Namespace $NS already gone, nothing to do"
        exit 0
      fi

      echo ">> Removing finalizers from ArgoCD Applications in $NS"
      kubectl get applications.argoproj.io -n "$NS" -o name 2>/dev/null | \
        xargs -r -I {} kubectl patch {} -n "$NS" --type=merge -p '{"metadata":{"finalizers":[]}}'

      echo ">> Removing finalizers from ArgoCD AppProjects in $NS"
      kubectl get appprojects.argoproj.io -n "$NS" -o name 2>/dev/null | \
        xargs -r -I {} kubectl patch {} -n "$NS" --type=merge -p '{"metadata":{"finalizers":[]}}'

      echo ">> Waiting up to 60s for namespace to terminate naturally"
      for i in $(seq 1 12); do
        if ! kubectl get namespace "$NS" >/dev/null 2>&1; then
          echo ">> Namespace $NS terminated"
          exit 0
        fi
        sleep 5
      done

      echo ">> Forcing namespace finalizer removal via /finalize API"
      kubectl get namespace "$NS" -o json 2>/dev/null | \
        jq '.spec.finalizers = []' | \
        kubectl replace --raw "/api/v1/namespaces/$NS/finalize" -f - >/dev/null 2>&1

      exit 0
    EOT
  }

  depends_on = [kubernetes_namespace_v1.services]
}