#============================================
# Global Variables
#============================================
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "environment" {
  description = "Environment (Homologação, Produção, etc)"
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

#============================================
# ECR Variables
#============================================
variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

#============================================
# EKS / IRSA Variables
#============================================
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL (issuer) of the IAM OIDC provider associated with the EKS cluster"
  type        = string
}