# mongodb
resource "aws_instance" "mongodb" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.mongodb_sg_id]  
    subnet_id = local.database_subnet_id 

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-mongodb"
        }
    )
}

resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  depends_on = [aws_instance.mongodb]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    =  "DevOps321"
    host        = aws_instance.mongodb.private_ip

  }

  # Step 1: Copy the .sh file to the server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  # Step 2: Set permissions and execute
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh mongodb"
    ]
  }
}

# redis
resource "aws_instance" "redis" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.redis_sg_id]  
    subnet_id = local.database_subnet_id 

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-redis"
        }
    )
}

resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  depends_on = [aws_instance.redis]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    =  "DevOps321"
    host        = aws_instance.redis.private_ip

  }

  # Step 1: Copy the .sh file to the server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  # Step 2: Set permissions and execute
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh redis"
    ]
  }
}

# rabbitmq
resource "aws_instance" "rabbitmq" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.rabbitmq_sg_id]  
    subnet_id = local.database_subnet_id 

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-rabbitmq"
        }
    )
}

resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  depends_on = [aws_instance.rabbitmq]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    =  "DevOps321"
    host        = aws_instance.rabbitmq.private_ip
  }

  # Step 1: Copy the .sh file to the server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  # Step 2: Set permissions and execute
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh rabbitmq"
    ]
  }
}

#mysql
resource "aws_instance" "mysql" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.mysql_sg_id]  
    subnet_id = local.database_subnet_id 
    iam_instance_profile   = "aws_iam_instance_profile.mysql.name"

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-mysql"
        }
    )
}

resource "aws_iam_instance_profile" "mysql" {
  name = "mysql"
  role = "EC2SSMParameterRead"
}


resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id
  ]

  depends_on = [aws_instance.mysql]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    =  "DevOps321"
    host        = aws_instance.mysql.private_ip
  }

  # Step 1: Copy the .sh file to the server
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  # Step 2: Set permissions and execute
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh mysql"
    ]
  }
}

# route53 records

resource "aws_route53_record" "mongodb" {
  zone_id = var.zone_id
  name    = "mongodb-${var.environment}-${var.domain_name}" #mongodb-dev-vicky08.fun
  type    = "A"
  ttl     = 1
  records = [aws_instance.mongodb.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "redis" {
  zone_id = var.zone_id
  name    = "redis-${var.environment}-${var.domain_name}" #redis-dev-vicky08.fun
  type    = "A"
  ttl     =  1
  records  = [aws_instance.redis.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zone_id
  name    = "rabbitmq-${var.environment}-${var.domain_name}" #rabbitmq-dev-vicky08.fun
  type    = "A"
  ttl     =  1
  records  = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "mysql" {
  zone_id = var.zone_id
  name    = "mysql-${var.environment}-${var.domain_name}" #mysql-dev-vicky08.fun
  type    = "A"
  ttl     =  1
  records  = [aws_instance.mysql.private_ip]
  allow_overwrite = true
}