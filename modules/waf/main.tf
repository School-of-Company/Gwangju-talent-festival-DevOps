resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-${var.environment}-waf"
  description = "${var.project_name} ${var.environment} ALB protection - rate limiting and common exploit rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitPerIp"
    priority = 0

    # 프록시(Vercel)가 X-Forwarded-For를 전달하지 않아 모든 요청이 단일 egress IP로 보임.
    # block으로 두면 실사용자 전체가 하나의 IP로 묶여 차단되므로, 프록시가 원본 IP를
    # 전달하도록 고치기 전까지는 count로 감시만 한다.
    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit_per_ip
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIp"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        # SizeRestrictions_BODY는 본문 8KB 초과 시 고정 차단(임계값 조정 불가).
        # 필기 저장 등 정상 요청이 걸려 count로 내림. 본문 크기 제한은
        # 백엔드 JudgeStrokesProperties(judge.strokes.max-bytes)가 대신 담당하고,
        # 나머지 서브룰(XSS/RFI 등)은 그대로 차단 모드로 유지.
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}${title(var.environment)}Waf"
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
