output "security_group_id" {
  description = "MySQL 보안 그룹 ID"
  value       = aws_security_group.mysql.id
}

output "private_ip" {
  description = "MySQL EC2 프라이빗 IP"
  value       = aws_instance.mysql.private_ip
}
