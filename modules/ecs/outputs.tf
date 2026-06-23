output "security_group_id" {
  description = "ECS 태스크 보안 그룹 ID (MySQL/Redis SG에서 참조)"
  value       = aws_security_group.ecs.id
}

output "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS 서비스 이름"
  value       = aws_ecs_service.app.name
}
