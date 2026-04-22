#============================================
# IAM — AWS Load Balancer Controller (IRSA)
#============================================
# Role assumível apenas pelo ServiceAccount
# aws-load-balancer-controller no namespace kube-system.
# Policy oficial em iam-alb-policy.json (v2.8.2).
#============================================

locals {
  alb_oidc_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.alb_oidc_host}:sub"
      values   = ["system:serviceaccount:${var.alb_namespace}:${var.alb_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.alb_oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.project_name}-${var.environment}-alb-controller"
  description = "AWS Load Balancer Controller policy (upstream v2.8.2)"
  policy      = file("${path.module}/iam-alb-policy.json")
  tags        = var.tags
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.project_name}-${var.environment}-alb-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
