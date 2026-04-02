output "redis_host" {
  description = "Redis primary endpoint hostname"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

output "redis_endpoint" {
  description = "Redis primary endpoint (host:port)"
  value       = "${aws_elasticache_replication_group.main.primary_endpoint_address}:6379"
}

output "replication_group_id" {
  description = "ElastiCache replication group ID"
  value       = aws_elasticache_replication_group.main.id
}
