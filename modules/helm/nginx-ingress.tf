#============================================
# NGINX Ingress Controller
#============================================
# Instala o chart oficial do Kubernetes (ingress-nginx).
# O controller expoe um Service type=LoadBalancer anotado para
# provisionar um NLB pela AWS Cloud Provider nativa.
#============================================

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_chart_version
  namespace  = var.nginx_namespace

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }

  wait          = true
  wait_for_jobs = true
  timeout       = 600
}
