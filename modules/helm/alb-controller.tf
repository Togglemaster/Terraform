#============================================
# AWS Load Balancer Controller
#============================================
# Instala o chart oficial da AWS e cria o ServiceAccount
# anotado com o ARN da role IRSA.
# Necessário para Ingress do tipo ALB e Service type=LoadBalancer (NLB).
#============================================

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.alb_chart_version
  namespace  = var.alb_namespace

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.alb_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [aws_iam_role_policy_attachment.alb_controller]
}
