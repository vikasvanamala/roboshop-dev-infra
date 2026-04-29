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
        "catalogue" , "cart" , "user" , "shipping" , "payment" ,
        # frontend servers
        "frontend" ,
        # loadbalancer
        "backend_alb" , "frontend_alb" ,
        # vpn
        "openvpn"
    ]  
}

variable "sg_description" {

    default = "security group"
}


# variable "sg_tags" {
#     type = map
#     default = {}
# }








