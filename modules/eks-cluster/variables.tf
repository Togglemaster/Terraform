#============================================
# Global Variables
#============================================
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (Homologação, Produção, etc)"
  type        = string
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}


# Public subnets to create the cluster. From Network Module
variable "public_subnet_ids" {
  type        = map(string)
  description = "Subnet IDs to create EKS cluster"
}