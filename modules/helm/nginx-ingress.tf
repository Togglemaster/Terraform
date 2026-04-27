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

#============================================
# Drain do NLB no destroy
#============================================
# O Service type=LoadBalancer cria um NLB *fora* do Terraform (via cloud
# controller do K8s). Sem este hook, o NLB fica orfao na hora do destroy
# e bloqueia o detach do IGW (DependencyViolation na VPC).
#
# Este null_resource depende do helm_release, entao na ordem de destroy
# ele e processado ANTES do helm uninstall: forca a remocao do Service
# via kubectl, espera a AWS confirmar que o NLB sumiu, e so entao o
# restante da pilha (EKS, VPC) e desmontado com seguranca.
#============================================
resource "null_resource" "nginx_lb_drain" {
  triggers = {
    region       = var.aws_region
    cluster_name = var.cluster_name
    vpc_id       = var.vpc_id
    namespace    = var.nginx_namespace
    service_name = "ingress-nginx-controller"
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      REGION="${self.triggers.region}"
      CLUSTER="${self.triggers.cluster_name}"
      VPC="${self.triggers.vpc_id}"
      NS="${self.triggers.namespace}"
      SVC="${self.triggers.service_name}"

      echo ">> Refreshing kubeconfig for $CLUSTER"
      aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER" >/dev/null 2>&1 || true

      echo ">> Deleting Service $NS/$SVC to release NLB"
      kubectl delete svc "$SVC" -n "$NS" --ignore-not-found --timeout=180s || true

      echo ">> Waiting for NLBs in VPC $VPC to be removed"
      for i in $(seq 1 36); do
        REMAINING=$(aws elbv2 describe-load-balancers --region "$REGION" \
          --query "length(LoadBalancers[?VpcId=='$VPC'])" --output text 2>/dev/null || echo "0")
        if [ "$REMAINING" = "0" ]; then
          echo ">> All NLBs cleaned up"
          exit 0
        fi
        echo "   $REMAINING NLB(s) still present... ($i/36)"
        sleep 10
      done

      echo ">> Timeout reached - force-deleting remaining NLBs"
      aws elbv2 describe-load-balancers --region "$REGION" \
        --query "LoadBalancers[?VpcId=='$VPC'].LoadBalancerArn" --output text \
        | tr '\t' '\n' | while read -r ARN; do
            [ -n "$ARN" ] && aws elbv2 delete-load-balancer --region "$REGION" --load-balancer-arn "$ARN"
          done
      sleep 30
    EOT
  }

  depends_on = [helm_release.nginx_ingress]
}
