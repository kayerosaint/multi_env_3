
output "vpc_cidr_block" {
  value = module.networking.vpc_cidr_blocks
}

output "private_subnets" {
  value = module.networking.private_subnets
}
