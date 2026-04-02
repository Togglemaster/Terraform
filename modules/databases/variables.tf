
#============================================
# Global Variables
#============================================
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment (Homologação, Produção, etc)"
  type        = string
}

#============================================
# VPC Variables
#============================================
#VPC ID
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

#============================================
# RDS Variables
#============================================
#RDS Password
variable "rds_password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = "testedbteste"
}