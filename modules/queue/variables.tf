variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags for the RDS instance"
  type        = map(string)
  default     = {}
}