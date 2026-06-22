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
variable "public_subnet_id" {
  description = "Bastion을 배치할 퍼블릭 서브넷 ID"
  type        = string
}
variable "instance_type" {
  description = "Bastion 인스턴스 타입"
  type        = string
}
variable "key_pair_name" {
  description = "SSH 키페어 이름"
  type        = string
}
variable "allowed_cidr" {
  description = "SSH 접근을 허용할 IP 대역"
  type        = string
}
