variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "배포 환경"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록 (가용영역 순서와 일치해야 함)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 목록 (가용영역 순서와 일치해야 함)"
  type        = list(string)
}

variable "availability_zones" {
  description = "서브넷을 배치할 가용영역 목록"
  type        = list(string)
}
