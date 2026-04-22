# ============================================================
# IRSA — External Secrets Operator
# ============================================================
# TODO: restringir Resource = "*" para ARNs específicos dos secrets
# após finalizar os testes iniciais.

data "aws_caller_identity" "current" {}

locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${var.eso_service_account_namespace}:${var.eso_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eso_secrets_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:BatchGetSecretValue",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eso_secrets_access" {
  name        = "${var.project_name}-${var.environment}-eso-secrets-access"
  description = "Permite ao External Secrets Operator ler secrets do Secrets Manager"
  policy      = data.aws_iam_policy_document.eso_secrets_access.json
  tags        = var.tags
}

resource "aws_iam_role" "eso" {
  name               = "${var.project_name}-${var.environment}-eso-irsa"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso_secrets_access.arn
}
