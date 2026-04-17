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

  repository_name = each.key
  tags            = var.tags
  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = module.eks.eks_cluster_name

  depends_on = [module.eks]
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

module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name           = var.project_name
  environment            = var.environment
  tags                   = var.tags
  rds_username           = var.rds_username
  db_passwords           = module.secrets_manager.app_passwords
  sqs_queue_url          = module.queue.sqs_queue_url
  db_auth_endpoint       = module.rds.rds_instance_address
  db_flag_endpoint       = module.rds.rds_instance_address
  db_targeting_endpoint  = module.rds.rds_instance_address
  evaluation_db_endpoint = module.rds.elasticache_endpoint
  dynamodb_table_name    = module.rds.dynamodb_table_name
}

module "secrets_manager" {
  source = "../../modules/secrets_manager"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  tags                  = var.tags
  private_subnet_ids    = values(module.vpc.private_subnet_ids)
  rds_security_group_id = module.rds.rds_security_group_id
  rds_address           = module.rds.rds_instance_address
  rds_port              = module.rds.rds_instance_port
  rds_db_name           = module.rds.rds_db_name
  rds_username          = var.rds_username

  redis_url           = "redis://${module.rds.elasticache_endpoint}:6379"
  sqs_url             = module.queue.sqs_queue_url
  dynamodb_table_name = module.rds.dynamodb_table_name
}