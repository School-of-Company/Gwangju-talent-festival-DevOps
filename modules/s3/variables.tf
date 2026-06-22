variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}
variable "environment" {
  description = "배포 환경"
  type        = string
}
variable "s3_bucket_name" {
  description = "S3 버킷 이름 (전역 고유값)"
  type        = string
}
