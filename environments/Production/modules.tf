module "vpc" {
  source = "../../modules/network"

  project_name = var.project_name
  environment  = var.environment
  cidr_block   = var.cidr_block
  tags         = var.tags
}

module "ecr" {
  source   = "../../modules/ecr"
  for_each = toset(var.repository_name)

  repository_name   = each.key
  tags              = var.tags
  project_name      = var.project_name
  environment       = var.environment
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "nodegroup" {
  source = "../../modules/eks-nodegroup"

  project_name       = var.project_name
  environment        = var.environment
  tags               = var.tags
  cluster_name       = module.eks.eks_cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_cluster_sg     = module.eks.cluster_sg
}

module "rds" {
  source = "../../modules/databases"

  project_name       = var.project_name
  environment        = var.environment
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.cidr_block
  private_subnet_ids = values(module.vpc.private_subnet_ids)
  rds_username       = var.rds_username
}

module "eks" {
  source = "../../modules/eks-cluster"

  project_name      = var.project_name
  environment       = var.environment
  tags              = var.tags
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "queue" {
  source = "../../modules/queue"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "secrets_manager" {
  source = "../../modules/secrets_manager"

  aws_region                 = var.aws_region
  project_name               = var.project_name
  environment                = var.environment
  tags                       = var.tags
  rds_address                = module.rds.rds_instance_address
  rds_port                   = module.rds.rds_instance_port
  rds_master_user_secret_arn = module.rds.rds_master_user_secret_arn

  redis_url           = "redis://${module.rds.elasticache_endpoint}:6379"
  sqs_url             = module.queue.sqs_queue_url
  dynamodb_table_name = module.rds.dynamodb_table_name

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

# Instala charts Helm: ESO, NGINX Ingress Controller, Metrics Server
module "helm" {
  source = "../../modules/helm"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  eso_role_arn = module.secrets_manager.eso_role_arn

  depends_on = [
    module.eks,
    module.nodegroup,
    module.secrets_manager,
  ]
}

# Recursos K8s nativos: namespaces + ClusterSecretStore + ExternalSecrets
module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  depends_on = [
    module.helm,
  ]
}
