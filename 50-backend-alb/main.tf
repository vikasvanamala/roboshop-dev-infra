resource "aws_lb" "backend_alb" {
  name               = "${local.common_name_suffix}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = false

  tags = merge (
    local.common_tags ,
        {
            name = "${local.common_name_suffix}-backend-alb"
        }

  )
}

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "hi iam from backenda-lb server"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id                 # The ID of your hosted zone
  name    = "*.backend-alb-${var.environment}.${var.domain_name}"  # The domain name for the record
  type    = "A"                            # Alias records typically use type A or AAAA

  alias {
    name                   = aws_lb.backend_alb.dns_name    # Target DNS name (e.g., from an ALB)
    zone_id                = aws_lb.backend_alb.zone_id    # Target hosted zone ID (specific to the resource)
    evaluate_target_health = true                   # Whether Route 53 checks target health
  }
}




