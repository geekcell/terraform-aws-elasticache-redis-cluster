output "primary_endpoint_address" {
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
  description = "Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
}

output "reader_endpoint_address" {
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
  description = "Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
}

output "auth_token" {
  value       = random_password.main_password.result
  description = "The generate auth token used to access the Redis cluster."
  sensitive   = true
}
