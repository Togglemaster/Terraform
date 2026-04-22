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
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

#============================================
# External Secrets Operator
#============================================
variable "eso_service_account_name" {
  type        = string
  description = "Nome do ServiceAccount do ESO (deve bater com a condição do trust policy da role IRSA)"
  default     = "external-secrets"
}

variable "eso_service_account_namespace" {
  type        = string
  description = "Namespace do ServiceAccount do ESO"
  default     = "external-secrets"
}
