variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}


variable "sg_names" {
    default = [
        # host
        "bastion" ,
        # databases
        "mongodb" , "redis" , "rabbitmq" , "mysql" ,
        # backend servers
        "catalogue" , 
        # loadbalancer
        "backend_alb" , "frontend_alb"

    ]  
}

variable "sg_description" {

    default = "security group"
}


# variable "sg_tags" {
#     type = map
#     default = {}
# }








