# Filtra apenas subnets públicas do map já existente
locals {
  public_subnets = {
    for key, subnet in var.subnets :
    key => subnet
    if subnet.type == "public"
  }
}

#============================================
# Elastic IP alocate (used by NGW)
#============================================
resource "aws_eip" "elastic_ip" {
  for_each = local.public_subnets # 1 EIP por subnet pública

  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-${each.key}"
    }
  )
}

#============================================
# NAT Gateway for the private subnets
#============================================
resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.public_subnets # 1 NGW por subnet pública

  allocation_id = aws_eip.elastic_ip[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}