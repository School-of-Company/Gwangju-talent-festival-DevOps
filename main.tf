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
  app_secrets  = var.app_secrets
}

module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
}

module "ecs" {
  source               = "./modules/ecs"
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  alb_target_group_arn = module.alb.target_group_arn
  alb_sg_id            = module.alb.alb_sg_id
  ecr_repository_url   = module.ecr.repository_url
  secrets_arn          = module.secrets_manager.secrets_arn
  secret_keys          = keys(var.app_secrets)
  extra_secret_keys    = ["GOOGLE_SHEETS_ACCOUNT_CREDENTIAL"]
  container_port       = var.container_port
  cpu                  = var.ecs_task_cpu
  memory               = var.ecs_task_memory
  desired_count        = var.ecs_desired_count
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
