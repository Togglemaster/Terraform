#============================================
# ElastiCache Module
#============================================
module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  replication_group_id = "${var.project_name}-redis-cluster-${var.environment}"

  # Cluster mode
  cluster_mode_enabled       = true
  num_node_groups            = 1
  replicas_per_node_group    = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Security group
  vpc_id = vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = var.vpc_cidr
    }
  }

  # Subnet Group
  subnet_ids = var.private_subnet_ids

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}_elasticache_${var.environment}"
    }
  )
}