output "bastion_public_ip" {
  description = "Bastion 퍼블릭 IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_sg_id" {
  description = "Bastion 보안 그룹 ID (MySQL/Redis SG에서 참조)"
  value       = aws_security_group.bastion.id
}
