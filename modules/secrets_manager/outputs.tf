output "secrets_arn" {
  description = "Secrets Manager ARN (ECS Task Definition에서 참조)"
  value       = aws_secretsmanager_secret.app.arn
}
