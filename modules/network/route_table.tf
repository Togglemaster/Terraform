# Filtra apenas subnets publicas do map já existente
locals {
  public_subnets = {
    for key, subnet in var.subnets :
    key => subnet
    if subnet.type == "public"
  }

  private_subnets = {
    for key, subnet in var.subnets :
    key => subnet
    if subnet.type == "private"
  }

  # Cria um map de AZ -> subnet key para lookup fácil
  public_subnet_by_az = {
    for key, subnet in var.subnets :
    subnet.az => key
    if subnet.type == "public"
  }
}

#============================================
# Route table for the public subnets
#============================================
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-route-table"
    }
  )
}

#============================================
# Route table for the private subnets
#============================================
resource "aws_route_table" "eks_rtb_priv_1a" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[local.public_subnet_by_az[each.value.az]].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-route-table-${each.key}"
    }
  )
}

#============================================
# Route table association to the public subnets
#============================================
resource "aws_route_table_association" "public_route_table_association" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public_route_table.id
}

#============================================
# Route table association to the private subnets
#============================================
resource "aws_route_table_association" "eks_priv_rtb_assoc_1a" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.eks_rtb_priv_1a[each.key].id
}