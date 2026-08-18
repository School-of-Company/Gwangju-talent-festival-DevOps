output "primary_endpoint" {
  description = "Redis Primary 엔드포인트 (앱의 REDIS_HOST로 사용)"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "port" {
  description = "Redis 포트"
  value       = aws_elasticache_replication_group.main.port
}

output "security_group_id" {
  description = "ElastiCache 보안 그룹 ID"
  value       = aws_security_group.redis.id
}
