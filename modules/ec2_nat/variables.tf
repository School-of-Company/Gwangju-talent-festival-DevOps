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
variable "vpc_cidr" {
  description = "VPC CIDR (NAT SG 인바운드 허용 대역)"
  type        = string
}
variable "public_subnet_id" {
  description = "NAT 인스턴스를 배치할 퍼블릭 서브넷 ID"
  type        = string
}
variable "private_route_table_ids" {
  description = "NAT 라우트를 추가할 프라이빗 라우트 테이블 ID 목록"
  type        = list(string)
}
variable "instance_type" {
  description = "NAT 인스턴스 타입"
  type        = string
}
variable "key_pair_name" {
  description = "SSH 키페어 이름"
  type        = string
}
