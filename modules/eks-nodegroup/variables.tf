#============================================
# Global Variables
#============================================
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "environment" {
  description = "Environment (Production, Staging, etc)"
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

#============================================
# EKS Node Group Variables
#============================================
variable "cluster_name" {
  type        = string
  description = "Cluster name to integrate node group with the cluster"
}

variable "private_subnet_ids" {
  type        = map(string)
  description = "Private subnet IDs where node group instances will run"
}

variable "eks_cluster_sg" {
  type        = string
  description = "Cluster security group ID for ingress rules"
}
