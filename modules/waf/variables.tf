variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}
variable "environment" {
  description = "배포 환경"
  type        = string
}
variable "alb_arn" {
  description = "WebACL을 연결할 ALB ARN"
  type        = string
}
variable "rate_limit_per_ip" {
  description = "IP당 5분간 허용할 최대 요청 수 (초과 시 차단)"
  type        = number
  default     = 1000
}
