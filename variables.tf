variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}
variable "environment" {
  description = "배포 환경"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC IP 대역"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 목록"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "availability_zones" {
  description = "서브넷을 배치할 가용영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}
variable "key_pair_name" {
  description = "EC2 SSH 접속 키페어 이름"
  type        = string
}
variable "nat_instance_type" {
  description = "NAT EC2 인스턴스 타입"
  type        = string
  default     = "t4g.nano"
}
variable "bastion_instance_type" {
  description = "Bastion EC2 인스턴스 타입"
  type        = string
  default     = "t4g.nano"
}
variable "bastion_allowed_cidr" {
  description = "Bastion SSH 허용 IP 대역"
  type        = string
  default     = "0.0.0.0/0"
}
variable "ecs_task_cpu" {
  description = "Fargate Task CPU 유닛"
  type        = number
  default     = 512
}
variable "ecs_task_memory" {
  description = "Fargate Task 메모리 (MiB)"
  type        = number
  default     = 1024
}
variable "ecs_desired_count" {
  description = "ECS 서비스 유지 태스크 수"
  type        = number
  default     = 1
}
variable "container_port" {
  description = "컨테이너 앱 포트"
  type        = number
  default     = 8080
}
variable "redis_instance_type" {
  description = "Redis EC2 인스턴스 타입"
  type        = string
  default     = "t4g.micro"
}
variable "mysql_instance_type" {
  description = "MySQL EC2 인스턴스 타입"
  type        = string
  default     = "t4g.micro"
}
variable "mysql_root_password" {
  description = "MySQL root 초기 비밀번호"
  type        = string
  sensitive   = true
}
variable "s3_bucket_name" {
  description = "S3 버킷 이름 (전역 고유값)"
  type        = string
}
variable "domain_name" {
  description = "ALB 연결 도메인"
  type        = string
}
variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}
variable "app_secrets" {
  description = "앱 시크릿 key-value 맵"
  type        = map(string)
  sensitive   = true
  default     = {}
}
