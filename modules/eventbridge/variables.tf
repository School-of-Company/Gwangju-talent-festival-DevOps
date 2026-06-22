variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경"
  type        = string
}

variable "lambda_arn" {
  description = "트리거할 Lambda ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda 함수 이름 (호출 권한 설정용)"
  type        = string
}
