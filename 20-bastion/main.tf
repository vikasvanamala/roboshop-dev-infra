resource "aws_instance" "bastion" {
    ami                    = local.ami_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [local.bastion_sg_id]  
    subnet_id = local.public_subnet_id 
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.bastion.name
    
    # Reads a script named "bastion.sh" in the same directory
  user_data = file("bastion.sh")

    tags = merge (
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-bastion"
        }
    )
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion"
  role = "BastionTerraformAdmin"
}