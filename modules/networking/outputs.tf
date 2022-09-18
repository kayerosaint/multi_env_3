

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "vpc_id" {
  value = try(data.aws_vpc.dev_vpc[*].id, "")
}

output "vpc_cidr_blocks" {
  value = try(data.aws_vpc.dev_vpc[*].cidr_block, "")
}

output "private_subnets" {
  value = aws_subnet.private
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnets[*].cidr_block
}
