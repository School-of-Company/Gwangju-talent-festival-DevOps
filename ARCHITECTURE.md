# 광탈페 인프라 설계 문서

## 프로젝트 개요

좌석 예매 서비스 (결제 없음) AWS 인프라 — Terraform IaC

- **리전**: ap-northeast-2 (서울)
- **환경**: dev
- **앱**: ECS Fargate (Docker, port 8080)

---

## 아키텍처

```
Internet
  ↓ HTTP 80 → HTTPS 443 리다이렉트
ALB (public subnet) + ACM 인증서
  ↓ HTTPS 443
ECS Fargate (private subnet, port 8080)
  ├── MySQL EC2  (private subnet, 3306)
  └── Redis EC2  (private subnet, 6379)

NAT EC2   (public subnet) → private 아웃바운드 인터넷
Bastion EC2 (public subnet) → SSH 접근

Lambda  → 예약 만료 배치 (EventBridge cron 트리거)
ECR     → Docker 이미지 저장
S3      → 정적 파일
Secrets Manager → DB / Redis / JWT 시크릿
Route53 → 도메인 → ALB DNS A record

GitHub Actions → PR 시 tfsec + Claude API 보안 자동 리뷰
```

---

## 네트워크 설계

| 구분 | CIDR | AZ |
|------|------|----|
| VPC | 10.0.0.0/16 | - |
| public-a | 10.0.1.0/24 | ap-northeast-2a |
| public-c | 10.0.2.0/24 | ap-northeast-2c |
| private-a | 10.0.11.0/24 | ap-northeast-2a |
| private-c | 10.0.12.0/24 | ap-northeast-2c |

---

## 폴더 구조

```
infra/
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars       # gitignore!
│
├── .github/
│   └── workflows/
│       └── tf-review.yml  # tfsec + Claude API PR 자동 리뷰
│
└── modules/
    ├── vpc/               # VPC, 서브넷, IGW, 라우팅 테이블
    ├── alb/               # ALB, ACM 인증서, 443 리스너, 80→443 리다이렉트, 타겟그룹
    ├── ec2_nat/           # NAT 인스턴스 (private outbound)
    ├── ec2_bastion/       # Bastion 인스턴스 (SSH 접근)
    ├── ecs/               # Fargate 클러스터, Task Def, Service, IAM Role
    ├── ec2_mysql/         # MySQL EC2 (user_data 설치)
    ├── ec2_redis/         # Redis EC2 (user_data 설치)
    ├── ecr/               # ECR 레포지토리
    ├── s3/                # S3 버킷
    ├── secrets_manager/   # Secrets Manager
    ├── lambda/            # Lambda 함수 (Python, 예약만료 배치)
    ├── eventbridge/       # EventBridge cron rule
    └── route53/           # A record alias → ALB
```

> `modules/sg/` 는 사용 안 함 — SG는 각 모듈이 자체 관리 (A방식)

---

## 모듈별 구현 명세

### vpc
- aws_vpc, aws_subnet (public×2, private×2), aws_internet_gateway
- aws_route_table (public/private 각각), aws_route_table_association
- **output**: vpc_id, public_subnet_ids, private_subnet_ids, private_route_table_ids

### alb
- aws_security_group (80, 443 인바운드 허용)
- aws_lb (internet-facing)
- aws_acm_certificate + aws_acm_certificate_validation (Route53 DNS 검증)
- aws_lb_listener: 443 HTTPS → 타겟그룹 forward
- aws_lb_listener: 80 HTTP → 443 redirect
- aws_lb_target_group (ip 타입, health check /health)
- **output**: alb_dns_name, alb_zone_id, target_group_arn, alb_sg_id

### ec2_nat
- aws_security_group (VPC CIDR 전체 허용, source_dest_check = false)
- aws_instance (Amazon Linux 2, NAT AMI 또는 user_data로 IP 포워딩 설정)
- aws_route (private route table → NAT 인스턴스)
- **output**: nat_instance_id

### ec2_bastion
- aws_security_group (22 포트, bastion_allowed_cidr에서만)
- aws_instance (Amazon Linux 2, t3.micro)
- **output**: bastion_public_ip, bastion_sg_id

### ecs
- aws_security_group (container_port, ALB SG에서만 허용)
- aws_ecs_cluster
- aws_ecs_task_definition (Fargate, ECR 이미지, Secrets Manager 환경변수)
- aws_ecs_service (private subnet, ALB 타겟그룹 연결)
- aws_iam_role + aws_iam_role_policy_attachment (task execution role)
- **output**: security_group_id, ecs_cluster_name, ecs_service_name

### ec2_mysql
- aws_security_group (3306: ECS SG에서만, 22: Bastion SG에서만)
- aws_instance (Amazon Linux 2, t4g.micro, user_data로 MySQL 설치)
- **output**: security_group_id, private_ip

### ec2_redis
- aws_security_group (6379: ECS SG에서만, 22: Bastion SG에서만)
- aws_instance (Amazon Linux 2, t3.small, user_data로 Redis 설치)
- **output**: security_group_id, private_ip

### ecr
- aws_ecr_repository (image_tag_mutability = MUTABLE)
- aws_ecr_lifecycle_policy (최근 이미지 10개만 보관)
- **output**: repository_url

### s3
- aws_s3_bucket + aws_s3_bucket_public_access_block (퍼블릭 차단)
- **output**: bucket_name, bucket_arn

### secrets_manager
- aws_secretsmanager_secret + aws_secretsmanager_secret_version
- **output**: secrets_arn

### lambda
- aws_iam_role (lambda execution role, CloudWatch Logs 권한)
- aws_lambda_function (Python 3.12, 예약만료 배치 껍데기)
- aws_cloudwatch_log_group
- **output**: lambda_arn, lambda_function_name

### eventbridge
- aws_cloudwatch_event_rule (cron 스케줄)
- aws_cloudwatch_event_target (Lambda 연결)
- aws_lambda_permission (EventBridge 호출 허용)

### route53
- aws_route53_record (A record alias → ALB)

---

## GitHub Actions — tfsec + Claude API PR 자동 리뷰

**파일**: `.github/workflows/tf-review.yml`

**트리거**: PR open/update, `.tf` 파일 변경 시만 실행

**플로우**:
```
1. git checkout
2. tfsec 실행 → JSON 결과 추출
3. git diff (변경된 .tf 파일)
4. Claude API 호출 (claude-haiku-4-5, tfsec 결과 + diff 전달)
5. GitHub API로 PR에 코멘트 자동 게시
```

**GitHub Secrets 필요**:
- `ANTHROPIC_API_KEY` — Claude API 키

**Claude 프롬프트 구조**:
- tfsec 발견 취약점 목록
- 변경된 Terraform diff
- 보안 위험도별 정리 (HIGH/MEDIUM/LOW)
- 수정 방법 제안

---

## 버그 픽스 목록 (루트 파일)

| 파일 | 문제 | 수정 |
|------|------|------|
| variables.tf | `lis(string)` | `list(string)` |
| variables.tf | private CIDR default에 AZ 이름 들어가 있음 | CIDR 값으로 교체 |
| main.tf | `source = "./modules/ec2-nat"` | `./modules/ec2_nat` |
| main.tf | `source = "./modules/ec2-bastion"` | `./modules/ec2_bastion` |
| main.tf | `source = "./modules/ec2-mysql"` | `./modules/ec2_mysql` |
| main.tf | `module.mysql.security_group_id` | `module.ec2_mysql.security_group_id` |
| main.tf | `lambda_functing_name` | `lambda_function_name` |
| terraform.tfvars | `mysql_instance_type = string` | `"t3.micro"` |
| terraform.tfvars | `app-northeast-2c` | `ap-northeast-2c` |

---

## 구현 순서

1. 루트 파일 버그 픽스 (variables.tf, main.tf, terraform.tfvars)
2. `vpc` 모듈
3. `alb` 모듈 (ACM 포함)
4. `ec2_nat`, `ec2_bastion` 모듈
5. `ecs` 모듈
6. `ec2_mysql`, `ec2_redis` 모듈
7. `ecr`, `s3`, `secrets_manager` 모듈
8. `lambda`, `eventbridge` 모듈
9. `route53` 모듈
10. `.github/workflows/tf-review.yml` (tfsec + Claude API)
