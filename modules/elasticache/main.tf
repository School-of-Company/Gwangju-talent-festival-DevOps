resource "aws_security_group" "redis" {
  name        = "${var.project_name}-elasticache-sg"
  description = "Allow ECS tasks to reach ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
    description     = "Allow Redis from ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnets"
  subnet_ids = var.private_subnet_ids
}

# 기존 EC2 self-hosted Redis(모듈: ec2_redis)를 대체하는 관리형 Redis.
# primary + replica 1개씩, 자동 failover 적용.
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "${var.project_name} ${var.environment} Redis (primary+replica)"
  engine                     = "redis"
  node_type                  = var.node_type
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
}
