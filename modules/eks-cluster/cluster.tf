#============================================
# EKS Cluster
#============================================
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn # Necessary role (iam.tf)
  version  = "1.31"                            # K8S version

  vpc_config {
    subnet_ids              = values(var.public_subnet_ids)
    endpoint_private_access = true # Internal access endpoint
    endpoint_public_access  = true # External access endpoint
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}