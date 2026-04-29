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
# Drain de Load Balancers do K8s no destroy
#============================================
# Services type=LoadBalancer no K8s criam NLBs/ALBs *fora* do Terraform
# (cloud controller). Sem este hook eles ficam orfaos no destroy e
# bloqueiam o detach do IGW (DependencyViolation na VPC).
#
# Este null_resource depende do helm_release, entao na ordem de destroy
# ele e processado ANTES do helm uninstall (e ANTES de EKS/VPC). Forca
# a remocao de TODOS os Services type=LoadBalancer via kubectl (nao so
# o nginx), espera a AWS confirmar que os LBs sumiram da VPC e, em
# ultimo caso, faz force-delete via API. A limpeza de ENIs/EIPs orfaos
# fica a cargo do safety-net no modulo network (cleanup.tf).
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
      set -uo pipefail
      REGION="${self.triggers.region}"
      CLUSTER="${self.triggers.cluster_name}"
      VPC="${self.triggers.vpc_id}"

      echo ">> Refreshing kubeconfig for $CLUSTER"
      aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER" >/dev/null 2>&1 || true

      echo ">> Coletando Services type=LoadBalancer no cluster"
      SVCS=$(kubectl get svc --all-namespaces \
        -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}' \
        2>/dev/null || true)

      if [ -n "$SVCS" ]; then
        echo "$SVCS" | while IFS= read -r SVC; do
          [ -n "$SVC" ] || continue
          NS="$${SVC%%/*}"
          NAME="$${SVC#*/}"
          echo "   delete svc $NS/$NAME"
          kubectl delete svc "$NAME" -n "$NS" --ignore-not-found --timeout=180s || true
        done
      else
        echo "   nenhum Service type=LoadBalancer encontrado (ou kubectl sem acesso)"
      fi

      echo ">> Aguardando NLBs/ALBs sumirem da VPC $VPC"
      for i in $(seq 1 36); do
        REMAINING=$(aws elbv2 describe-load-balancers --region "$REGION" \
          --query "length(LoadBalancers[?VpcId=='$VPC'])" --output text 2>/dev/null || echo "0")
        if [ "$REMAINING" = "0" ]; then
          echo "   OK - todos LBs limpos"
          exit 0
        fi
        echo "   $REMAINING LB(s) ainda presente(s)... ($i/36)"
        sleep 10
      done

      echo ">> Timeout - force-delete dos LBs restantes"
      aws elbv2 describe-load-balancers --region "$REGION" \
        --query "LoadBalancers[?VpcId=='$VPC'].LoadBalancerArn" --output text 2>/dev/null \
        | tr '\t' '\n' | while read -r ARN; do
            [ -n "$ARN" ] && aws elbv2 delete-load-balancer --region "$REGION" --load-balancer-arn "$ARN" || true
          done
      sleep 30
    EOT
  }

  depends_on = [helm_release.nginx_ingress]
}
