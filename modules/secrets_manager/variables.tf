variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}
variable "environment" {
  description = "배포 환경"
  type        = string
}
variable "app_secrets" {
  description = "앱 시크릿 key-value 맵"
  type        = map(string)
  sensitive   = true
}
