variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경"
  type        = string
}

variable "vpc_id" {
  description = "ALB를 배치할 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB를 배치할 퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "container_port" {
  description = "컨테이너 앱 포트 (헬스체크 타겟)"
  type        = number
}

variable "domain_name" {
  description = "ACM 인증서 및 Route53에 사용할 도메인"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID (ACM DNS 검증용)"
  type        = string
}
