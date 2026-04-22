# =============================================================================
# VARIÁVEIS GLOBAIS DO PROJETO
# =============================================================================
aws_region     = "us-east-1"
project_name   = "togglemaster"
environment    = "staging"
cidr_block     = "10.0.0.0/16"
aws_account_id = "654654467270" # Updated to current account

# =============================================================================
# VARIÁVEIS DE TAGS GLOBAIS
# =============================================================================
tags = {
  team        = "DevOps"
  project     = "togglemaster"
  environment = "staging"
  managedBy   = "Terraform"
}