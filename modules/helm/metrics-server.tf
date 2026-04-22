#============================================
# Metrics Server
#============================================
# Fornece métricas de CPU/memória via API metrics.k8s.io.
# Necessário para o HPA (HorizontalPodAutoscaler) funcionar.
# No EKS não vem instalado por padrão.
#============================================

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_chart_version
  namespace  = var.metrics_server_namespace

  # Adiciona flag recomendada para EKS (kubelet com cert self-signed).
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  wait    = true
  timeout = 300
}
