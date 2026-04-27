resource "aws_lb" "frontend_alb" {
  name               = "${local.common_name_suffix}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = merge (
    local.common_tags ,
        {
            name = "${local.common_name_suffix}-frontend-alb"
        }

  )
}

resource "aws_lb_listener" "roboshop" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09" # Recommended default policy
  certificate_arn   = "local.frontend_alb_certificate_arn"

   default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "<h1> hi, iam from roboshop dev frontend alb </h1> "
      status_code  = "200"
    }
  }
}


resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id                 # The ID of your hosted zone
  name    = "roboshop-${var.environment}.${var.domain_name}"  # roboshop-dev.vicky08.fun
  type    = "A"                            # Alias records typically use type A or AAAA
  allow_overwrite = true

  alias {
    name                   = aws_lb.frontend_alb.dns_name    # Target DNS name (e.g., from an ALB)
    zone_id                = aws_lb.frontend_alb.zone_id    # Target hosted zone ID (specific to the resource)
    evaluate_target_health = true                   # Whether Route 53 checks target health
  }
}




