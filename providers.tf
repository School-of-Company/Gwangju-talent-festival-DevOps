terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 팀 협업 시 상태파일을 S3에 저장 (로컬 tfstate 공유 방지)
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "infra/terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   dynamodb_table = "terraform-lock"  # 동시 apply 방지용 락
  #   encrypt        = true
  # }

}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
