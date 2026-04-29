resource "aws_instance" "openvpn" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.openvpn_sg_id]  
    subnet_id = local.public_subnet_id 

    # Reads a script named "bastion.sh" in the same directory
  user_data = file("vpn.sh")

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-openvpn"
        }
    )
}

resource "aws_route53_record" "openvpn" {
  zone_id = var.zone_id
  name    = "openvpn.${var.domain_name}" #openvpn.vicky08.fun
  type    = "A"
  ttl     = 1
  records = [aws_instance.openvpn.public_ip]
  allow_overwrite = true
}




