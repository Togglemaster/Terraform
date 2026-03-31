variable "repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "environment" {
  description = "Ambiente (Homologação, Produção, etc)"
  type        = string
}

variable "tags" {
  description = "Tags para aplicar ao repositório ECR"
  type        = map(string)
  default     = {}
}

variable "aws_account_id" {
  description = "ID da conta AWS"
  type        = string
}

variable "repository_name" {
  description = "Lista de nomes dos repositórios ECR"
  type        = list(string)
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}