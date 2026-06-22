output "alb_dns_name" {
  description = "ALB DNS 이름 (Route53 alias 레코드에 사용)"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Hosted Zone ID (Route53 alias에 사용)"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ECS 서비스 연결용 타겟그룹 ARN"
  value       = aws_lb_target_group.main.arn
}

output "alb_sg_id" {
  description = "ALB 보안 그룹 ID (ECS SG에서 참조)"
  value       = aws_security_group.alb.id
}
