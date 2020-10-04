output "vpc_id" {
  value = module.vpc.vpc_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# Subnets
output "public_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.public_subnets
}

# Subnets
output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = module.vpc.public_network_acl_id
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.vpc.private_network_acl_id
}

output "database_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.vpc.database_network_acl_id
}