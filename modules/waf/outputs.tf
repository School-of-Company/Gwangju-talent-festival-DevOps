output "web_acl_arn" {
  description = "생성된 WebACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}
