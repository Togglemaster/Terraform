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
  description = "ECR repository names"
  type        = list(string)
}

#============================================
# EKS Variables
#============================================
# To provide cluster name for IAM role (access to ECR)
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}