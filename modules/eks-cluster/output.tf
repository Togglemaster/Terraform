# Creating outputs that will go outside the module
output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
output "cluster_sg" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}
output "oidc" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
output "certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority
}