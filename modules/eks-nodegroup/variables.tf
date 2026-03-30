# Variable for the CIDR BLOCK to be used for the VPC
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

variable "key-pair" {
  type        = string
  description = "Key-Pair to the EC2 from MNG"
}


# Cluster name
variable "cluster_name" {
  type        = string
  description = "Cluster name to be used for integrate mng to cluster"
}


# Private subnets to create the MNG. From Network Module
variable "private_subnet_ids" {
  type        = map(string)
  description = "Subnet IDs to create EKS manage node group"
}

variable "eks_cluster_sg" {
  type        = string
  description = "Cluster SG to ingress rules"
}

