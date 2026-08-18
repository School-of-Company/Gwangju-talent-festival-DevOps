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
  description = "ElastiCache를 배치할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}
variable "ecs_sg_id" {
  description = "ECS 태스크 보안 그룹 ID (Redis 인바운드 허용 소스)"
  type        = string
}
variable "node_type" {
  description = "ElastiCache 노드 타입"
  type        = string
  default     = "cache.t4g.micro"
}
