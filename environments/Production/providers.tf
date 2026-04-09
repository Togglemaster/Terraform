terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    kubernetes = { #kubernetes
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#Kubernetes provider to exec a job
data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.eks_cluster_name
}

provider "kubernetes" { #kubernetes
  host = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.eks.cluster_authentic
  )

  token = data.aws_eks_cluster_auth.cluster_auth.token
}