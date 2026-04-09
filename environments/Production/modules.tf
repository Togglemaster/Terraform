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
}

module "rds" {
  source = "../../modules/databases"

  project_name       = var.project_name
  environment        = var.environment
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_username       = var.rds_username
  rds_password       = var.rds_password
}

module "eks" {
  source = "../../modules/eks-cluster"

  project_name      = var.project_name
  environment       = var.environment
  tags              = var.tags
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name           = var.project_name
  environment            = var.environment
  tags                   = var.tags
  rds_username           = var.rds_username
  rds_password           = var.rds_password
  sqs_queue_url          = var.sqs_queue_url
  db_auth_endpoint       = var.db_auth_endpoint
  db_flag_endpoint       = var.db_flag_endpoint
  db_targeting_endpoint  = var.db_targeting_endpoint
  evaluation_db_endpoint = var.evaluation_db_endpoint
  dynamodb_table_name    = var.dynamodb_table_name
}

module "secrets_manager" {
  source = "../../modules/secrets_manager"

  aws_region            = var.aws_region
  project_name          = var.project_name
  environment           = var.environment
  tags                  = var.tags
  app_names             = var.app_names
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.rds.rds_security_group_id
  rds_address           = module.rds.rds_instance_address
  rds_port              = module.rds.rds_instance_port
  rds_db_name           = module.rds.rds_db_name
}