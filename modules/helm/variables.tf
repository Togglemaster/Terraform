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

variable "aws_region" {
  type        = string
  description = "Região AWS (usada pelo ALB Controller)"
}

#============================================
# EKS / OIDC (para IRSA)
#============================================
variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS (usado pelo ALB Controller)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID onde o cluster roda (usado pelo ALB Controller)"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN do OIDC provider do EKS (para trust policy das roles IRSA)"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL do OIDC provider do EKS (para condições sub/aud das roles IRSA)"
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
# AWS Load Balancer Controller
#============================================
variable "alb_namespace" {
  type        = string
  description = "Namespace onde o ALB Controller será instalado"
  default     = "kube-system"
}

variable "alb_service_account_name" {
  type        = string
  description = "Nome do ServiceAccount do ALB Controller (deve bater com o trust policy da role IRSA)"
  default     = "aws-load-balancer-controller"
}

variable "alb_chart_version" {
  type        = string
  description = "Versão do chart aws-load-balancer-controller"
  default     = "1.9.2"
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
