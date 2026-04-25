locals {
  common_tags = {
        Project = var.project_name
        Environment = var.environment
        Terraform = true
  }
  common_name_suffix = "${var.project_name}-${var.environment}" # roboshop-dev
  ami_id = data.aws_ami.joindevops.id
  bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
  public_subnet_id = split("," , data.aws_ssm_parameter.public_subnet_ids.value)[0]
}