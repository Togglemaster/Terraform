#============================================
# Globais
#============================================
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

#============================================
# External Secrets Operator
#============================================
variable "eso_role_arn" {
  type        = string
  description = "ARN da role IRSA que o ServiceAccount do ESO deve assumir"
}

variable "eso_namespace" {
  type        = string
  description = "Namespace onde o ESO será instalado"
  default     = "external-secrets"
}

variable "eso_service_account_name" {
  type        = string
  description = "Nome do ServiceAccount do ESO (deve bater com o trust policy da role IRSA)"
  default     = "external-secrets"
}

variable "eso_chart_version" {
  type        = string
  description = "Versão do chart external-secrets"
  default     = "0.10.7"
}

#============================================
# NGINX Ingress Controller
#============================================
variable "nginx_namespace" {
  type        = string
  description = "Namespace onde o NGINX Ingress Controller será instalado"
  default     = "ingress-nginx"
}

variable "nginx_chart_version" {
  type        = string
  description = "Versão do chart ingress-nginx"
  default     = "4.11.3"
}

#============================================
# Metrics Server
#============================================
variable "metrics_server_namespace" {
  type        = string
  description = "Namespace onde o Metrics Server será instalado"
  default     = "kube-system"
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Versão do chart metrics-server"
  default     = "3.12.2"
}
