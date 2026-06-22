output "nat_instance_id" {
  description = "NAT 인스턴스 ID"
  value       = aws_instance.nat.id
}
