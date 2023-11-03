

variable "name" {
  description = "WebSG"
}



variable "ingress_rules" {
  default = [{
    from_port   = 443
    to_port     = 443
    description = "Port 443"
    cidr_block = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      description = "Port 80"
      cidr_block = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      description = "Port 22"
      cidr_block = "0.0.0.0/0"
    }

  ]
}

variable "egress_rules" {
  default = [{
    from_port   = 0
    to_port     = 65535
    description = "Allow All Traffic"
    cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "vpc_id" {

  default = ""

}

