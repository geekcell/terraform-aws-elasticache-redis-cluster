output "primary_endpoint_address" {
  value       = module.basic-example.primary_endpoint_address
  description = "Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
}

output "reader_endpoint_address" {
  value       = module.basic-example.reader_endpoint_address
  description = "Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
}
