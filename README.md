# 광탈페 인프라

좌석 예매 서비스 AWS 인프라 — Terraform IaC

## 아키텍처

```
Internet
  ↓ HTTP 80 → HTTPS 443 리다이렉트
ALB (public subnet) + ACM 인증서
  ↓ HTTPS 443
ECS Fargate (private subnet, port 8080)
  ├── MySQL EC2  (private subnet, 3306)
  └── Redis EC2  (private subnet, 6379)

NAT EC2    (public subnet) → private 아웃바운드 인터넷
Bastion EC2 (public subnet) → SSH 접근
Lambda     → 예약 만료 배치 (EventBridge cron)
```

## 모듈 구성

| 모듈 | 역할 |
|------|------|
| `vpc` | VPC, 서브넷, IGW, 라우팅 |
| `alb` | ALB, ACM 인증서, HTTPS 리스너 |
| `ec2_nat` | NAT 인스턴스 |
| `ec2_bastion` | Bastion 호스트 |
| `ecs` | ECS Fargate 클러스터/서비스 |
| `ec2_mysql` | MySQL EC2 |
| `ec2_redis` | Redis EC2 |
| `ecr` | ECR 레포지토리 |
| `s3` | S3 버킷 |
| `secrets_manager` | Secrets Manager |
| `lambda` | Lambda 배치 함수 |
| `eventbridge` | EventBridge cron 스케줄 |
| `route53` | Route53 A 레코드 |

## 사전 준비

1. AWS CLI 설정 (`aws configure`)
2. Terraform >= 1.5.0 설치
3. AWS 콘솔에서 EC2 키페어 생성
4. Route53 호스팅 영역 생성 및 도메인 연결

## 사용법

```bash
# 변수 파일 준비
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 실제 값으로 수정

# 초기화
terraform init

# 플랜 확인
terraform plan

# 배포
terraform apply
```

## GitHub Actions — PR 보안 자동 리뷰

`.tf` 파일 변경 PR 생성 시 tfsec + Claude AI가 자동으로 보안 리뷰를 코멘트로 남깁니다.

**설정 필요:**
- GitHub Repository Secrets에 `ANTHROPIC_API_KEY` 추가

## 주의사항

- `terraform.tfvars`는 `.gitignore`에 포함됨 — 커밋하지 말 것
- `bastion_allowed_cidr`는 운영 시 본인 IP로 변경 권장
- MySQL/Redis는 EC2 기반 (비용 절감 목적), 운영 환경에서는 RDS/ElastiCache 검토

