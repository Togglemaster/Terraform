# Variable definition for subnets
variable "subnets" {

  type = map(object({
    type      = string
    public_ip = bool
    az        = string
  }))

  default = {
    # Public subnets
    public_a = {
      type      = "public"
      public_ip = true
      az        = "us-east-1a"
    }
    public_b = {
      type      = "public"
      public_ip = true
      az        = "us-east-1b"
    }
    # Private subnets
    private_a = {
      type      = "private"
      public_ip = false
      az        = "us-east-1a"
    }
    private_b = {
      type      = "private"
      public_ip = false
      az        = "us-east-1b"
    }
  }
}

# Include index in subnets map
locals {
  subnets_indexed = {
    for i, key in keys(var.subnets) :
    key => merge(var.subnets[key], { index = i })
  }
}

#============================================
# Subnets for the EKS Cluster
#============================================
resource "aws_subnet" "subnets" {
  for_each = local.subnets_indexed

  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.az

  cidr_block = cidrsubnet(
    var.cidr_block,
    8,
    each.value.index
  ) # Function to create a subnet within the CIDR Block

  map_public_ip_on_launch = each.value.public_ip

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${each.key}-subnet"

      "kubernetes.io/role/elb"          = each.value.type == "public" ? "1" : null
      "kubernetes.io/role/internal-elb" = each.value.type == "private" ? "1" : null
    }
  )
}
