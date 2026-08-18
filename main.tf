# ElastiCache의 REDIS_HOST를 app_secrets에 자동으로 덮어써서,
# tfvars에 옛날 self-hosted Redis IP가 남아있어도 항상 최신 엔드포인트를 쓰도록 함.
locals {
  app_secrets_effective = merge(var.app_secrets, {
    REDIS_HOST = module.elasticache.primary_endpoint
    REDIS_PORT = tostring(module.elasticache.port)
  })
}

module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "ec2_nat" {
  source                  = "./modules/ec2_nat"
  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = var.vpc_cidr
  public_subnet_id        = module.vpc.public_subnet_ids[0]
  private_route_table_ids = module.vpc.private_route_table_ids
  instance_type           = var.nat_instance_type
  key_pair_name           = var.key_pair_name
}

module "ec2_bastion" {
  source           = "./modules/ec2_bastion"
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  instance_type    = var.bastion_instance_type
  key_pair_name    = var.key_pair_name
  allowed_cidr     = var.bastion_allowed_cidr
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

module "secrets_manager" {
  source       = "./modules/secrets_manager"
  project_name = var.project_name
  environment  = var.environment
  app_secrets  = local.app_secrets_effective
}

module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
}

module "alb" {
  source              = "./modules/alb"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  container_port      = var.container_port
  acm_certificate_arn = "arn:aws:acm:ap-northeast-2:879204766191:certificate/49810aa5-1b30-4eb9-9b50-6f770eaff120"
}

module "ecs" {
  source                   = "./modules/ecs"
  project_name             = var.project_name
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  alb_target_group_arn     = module.alb.target_group_arn
  alb_sg_id                = module.alb.alb_sg_id
  ecr_repository_url       = module.ecr.repository_url
  secrets_arn              = module.secrets_manager.secrets_arn
  secret_keys              = keys(local.app_secrets_effective)
  extra_secret_keys        = ["GOOGLE_SHEETS_ACCOUNT_CREDENTIAL"]
  container_port           = var.container_port
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  desired_count            = var.ecs_desired_count
  autoscaling_min_capacity = var.ecs_autoscaling_min_capacity
  autoscaling_max_capacity = var.ecs_autoscaling_max_capacity
  autoscaling_target_cpu   = var.ecs_autoscaling_target_cpu
}

module "ec2_mysql" {
  source              = "./modules/ec2_mysql"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_id   = module.vpc.private_subnet_ids[0]
  instance_type       = var.mysql_instance_type
  key_pair_name       = var.key_pair_name
  ecs_sg_id           = module.ecs.security_group_id
  bastion_sg_id       = module.ec2_bastion.bastion_sg_id
  mysql_root_password = var.mysql_root_password
}

module "ec2_redis" {
  # 참고: 관리형 ElastiCache(module.elasticache)로 대체됨.
  # 이 EC2 Redis는 전환 안정성 확인 기간 동안만 병행 유지 중이며,
  # 확인 끝나면 이 모듈 블록을 제거하고 main.tf에서 정리할 예정.
  source            = "./modules/ec2_redis"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids[0]
  instance_type     = var.redis_instance_type
  key_pair_name     = var.key_pair_name
  ecs_sg_id         = module.ecs.security_group_id
  bastion_sg_id     = module.ec2_bastion.bastion_sg_id
}

module "elasticache" {
  source             = "./modules/elasticache"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.ecs.security_group_id
  node_type          = var.elasticache_node_type
}

module "waf" {
  source            = "./modules/waf"
  project_name      = var.project_name
  environment       = var.environment
  alb_arn           = module.alb.alb_arn
  rate_limit_per_ip = var.waf_rate_limit_per_ip
}

module "lambda" {
  source       = "./modules/lambda"
  project_name = var.project_name
  environment  = var.environment
}

module "eventbridge" {
  source               = "./modules/eventbridge"
  project_name         = var.project_name
  environment          = var.environment
  lambda_arn           = module.lambda.lambda_arn
  lambda_function_name = module.lambda.lambda_function_name
}

module "route53" {
  source         = "./modules/route53"
  project_name   = var.project_name
  environment    = var.environment
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
}
