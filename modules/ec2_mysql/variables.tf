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
variable "private_subnet_id" {
  description = "MySQL EC2를 배치할 프라이빗 서브넷 ID"
  type        = string
}
variable "instance_type" {
  description = "MySQL EC2 인스턴스 타입"
  type        = string
}
variable "key_pair_name" {
  description = "SSH 키페어 이름"
  type        = string
}
variable "ecs_sg_id" {
  description = "ECS 보안 그룹 ID (3306 포트 허용 소스)"
  type        = string
}
variable "bastion_sg_id" {
  description = "Bastion 보안 그룹 ID (22 포트 허용 소스)"
  type        = string
}
variable "mysql_root_password" {
  description = "MySQL root 비밀번호"
  type        = string
  sensitive   = true
}
