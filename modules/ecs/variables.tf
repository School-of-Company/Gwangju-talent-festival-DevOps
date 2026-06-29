variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}
variable "environment" {
  description = "배포 환경"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "private_subnet_ids" {
  description = "ECS 태스크를 실행할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}
variable "alb_target_group_arn" {
  description = "ALB 타겟그룹 ARN"
  type        = string
}
variable "alb_sg_id" {
  description = "ALB 보안 그룹 ID (ECS SG 인바운드 허용 소스)"
  type        = string
}
variable "ecr_repository_url" {
  description = "ECR 레포지토리 URL"
  type        = string
}
variable "secrets_arn" {
  description = "Secrets Manager 시크릿 ARN"
  type        = string
}
variable "container_port" {
  description = "컨테이너 포트"
  type        = number
}
variable "cpu" {
  description = "Fargate Task CPU 유닛"
  type        = number
}
variable "memory" {
  description = "Fargate Task 메모리 (MiB)"
  type        = number
}
variable "desired_count" {
  description = "유지할 태스크 수"
  type        = number
}
variable "secret_keys" {
  description = "Secrets Manager에서 컨테이너에 주입할 환경변수 키 목록"
  type        = list(string)
  default     = []
}
variable "extra_secret_keys" {
  description = "tfvars 외부에서 추가할 시크릿 키 목록 (예: GOOGLE_SHEETS_ACCOUNT_CREDENTIAL)"
  type        = list(string)
  default     = []
}
