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

#============================================
# Variables to be used for the network module
#============================================
# Variable for the CIDR BLOCK to be used for the VPC
variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}