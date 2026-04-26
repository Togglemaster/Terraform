#============================================
# Creating a Manage Node Group
#============================================
resource "aws_eks_node_group" "eks_manage_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_mng_role.arn
  ami_type        = "AL2023_x86_64_STANDARD"
  instance_types  = ["t3.small"]

  subnet_ids = values(var.private_subnet_ids)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nodegroup"
    }
  )

  # Defining the desired scling config
  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 3
  }

  # Defining dependencies with roles to create and delete them without problems
  depends_on = [
    aws_iam_role_policy_attachment.eks_mng_role_attachment_worker,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_cni,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_registry,
  ]
}
