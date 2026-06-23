output "security_group_id" {
  description = "Redis 보안 그룹 ID"
  value       = aws_security_group.redis.id
}

output "private_ip" {
  description = "Redis EC2 프라이빗 IP"
  value       = aws_instance.redis.private_ip
}
