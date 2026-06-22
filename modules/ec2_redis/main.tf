data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
    description     = "Allow Redis from ECS"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
    description     = "Allow SSH from Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_instance" "redis" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.redis.id]
  private_ip             = "10.0.11.20"

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y redis6
    systemctl start redis6
    systemctl enable redis6
    sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis6.conf
    systemctl restart redis6
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

  tags = { Name = "${var.project_name}-${var.environment}-redis" }
}
