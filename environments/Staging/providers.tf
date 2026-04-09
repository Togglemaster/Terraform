terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    kubernetes = {                     #kubernetes
      source  = "hashicorp/kubernetes" #kubernetes
      version = "3.0.1"                #kubernetes
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#Kubernetes provider to exec a job
provider "kubernetes" {
  host = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.eks.cluster_authentic
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name", var.eks_cluster_name,
    ]
  }
}