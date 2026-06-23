output "repository_url" {
  description = "ECR 레포지토리 URL (ECS Task Definition에 사용)"
  value       = aws_ecr_repository.main.repository_url
}
