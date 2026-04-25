resource "aws_instance" "catalogue" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.catalogue_sg_id]  
    subnet_id = local.private_subnet_id

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-catalogue"
        }
    )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]


  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    =  "DevOps321"
    host        = aws_instance.catalogue.private_ip
  }

  # Step 1: Copy the .sh file to the server
  provisioner "file" {
    source      = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  # Step 2: Set permissions and execute
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/catalogue.sh",
      "sudo /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }
}



resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_name_suffix}-catalogue-ami"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [aws_ec2_instance_state.catalogue]

  tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-catalogue-ami"
        }
    )

}

resource "aws_lb_target_group" "catalogue" {
  name        = "${local.common_name_suffix}-catalogue"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  deregistration_delay = 60 # waiting period before deleting the instance

    health_check {
    path                = "/health"
    port                = "8080"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200-299"
  }
}

resource "aws_launch_template" "catalogue" {
  name   = "${local.common_name_suffix}-catalogue"
  image_id      = aws_ami_from_instance.catalogue.id  # Replace with valid AMI ID

  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"

  # Network and Security
  vpc_security_group_ids = [local.catalogue_sg_id]

  update_default_version = true
  

  # Tags applied to the instance at launch
  tag_specifications {
    resource_type = "instance"
    tags = merge (
      local.common_tags,  {
      Name = "${local.common_name_suffix}-catalogue"
      }
    )
  }

  # tags created for volume created
  tag_specifications {
    resource_type = "volume"
    tags = merge (
      local.common_tags,  {
      Name = "${local.common_name_suffix}-catalogue"
      }
    )
  }

  # tags for launch template
  tags = merge (
    local.common_tags,  {
    Name = "${local.common_name_suffix}-catalogue"
    }
  )
}

resource "aws_autoscaling_group" "catalogue" {
  name = "${local.common_name_suffix}-catalogue"
  desired_capacity   = 1
  max_size           = 10
  min_size           = 1
  health_check_grace_period = 100
  health_check_type         = "ELB"
  force_delete              = false

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }
  vpc_zone_identifier       = local.private_subnet_ids
  target_group_arns = [aws_lb_target_group.catalogue.arn]


  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }  
  dynamic "tag" {
    for_each = merge (
      local.common_tags, 
      {
        Name = "${local.common_name_suffix}-catalogue"
      }
    ) 
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }
  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${local.common_name_suffix}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0 # Target 50% average CPU utilization
  }

}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"] #catalogue-backend_alb-dev.vicky08.fun
    }
  }
}

resource "terraform_data" "catalogue_local" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  # Step 2: Set permissions and execute
  depends_on = [aws_autoscaling_policy.catalogue]
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
    
  }
}



