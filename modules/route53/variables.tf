variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경"
  type        = string
}

variable "domain_name" {
  description = "A 레코드로 등록할 도메인"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS 이름 (alias 타겟)"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB Hosted Zone ID (alias에 필요)"
  type        = string
}
