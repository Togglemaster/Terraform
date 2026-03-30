#Subnets Output
output "public_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.subnets :
    key => subnet.id
    if var.subnets[key].type == "public"
  }
}

output "private_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.subnets :
    key => subnet.id
    if var.subnets[key].type == "private"
  }
}

#VPC Output
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}