data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "mysql" {
  name        = "${var.project_name}-${var.environment}-mysql-sg"
  description = "MySQL security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
    description     = "Allow MySQL from ECS"
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

resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  private_ip             = "10.0.11.10"

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y mysql-server
    systemctl start mysqld
    systemctl enable mysqld
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${var.mysql_root_password}';"
    mysql -u root -p'${var.mysql_root_password}' -e "CREATE DATABASE IF NOT EXISTS appdb;"
    mysql -u root -p'${var.mysql_root_password}' -e "CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY '${var.mysql_root_password}';"
    mysql -u root -p'${var.mysql_root_password}' -e "GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'%'; FLUSH PRIVILEGES;"
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

  tags = { Name = "${var.project_name}-${var.environment}-mysql" }
}
