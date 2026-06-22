output "lambda_arn" {
  description = "Lambda 함수 ARN (EventBridge 타겟에 사용)"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "Lambda 함수 이름 (EventBridge 권한 설정에 사용)"
  value       = aws_lambda_function.main.function_name
}
