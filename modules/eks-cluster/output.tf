# Creating outputs that will go outside the module
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_sg" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "oidc" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks_oidc.url
}

# Returns the base64-encoded PEM string — use base64decode() in the consumer
output "certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
