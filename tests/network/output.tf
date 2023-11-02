output "security_group_id" {
  value = module.redis_security_group.security_group_id
}

output "elasticache_subnet_group_name" {
  value = module.vpc.elasticache_subnet_group_name
}
