data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "nat" {
  name        = "${var.project_name}-${var.environment}-nat-sg"
  description = "NAT instance security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all traffic from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound for NAT"
  }
}

resource "aws_instance" "nat" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.nat.id]
  source_dest_check      = false

  user_data = <<-EOF
    #!/bin/bash
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    dnf install -y iptables
    iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
    iptables-save > /etc/iptables.rules
    cat > /etc/systemd/system/iptables-restore.service << 'SVCEOF'
    [Unit]
    Description=Restore iptables NAT rules
    Before=network-pre.target
    Wants=network-pre.target
    [Service]
    Type=oneshot
    ExecStart=/sbin/iptables-restore /etc/iptables.rules
    RemainAfterExit=yes
    [Install]
    WantedBy=multi-user.target
    SVCEOF
    systemctl enable --now iptables-restore
  EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

  tags = { Name = "${var.project_name}-${var.environment}-nat" }
}

resource "aws_route" "private_nat" {
  count                  = length(var.private_route_table_ids)
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}
