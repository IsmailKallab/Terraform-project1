resource "aws_security_group" "ALBSG" {
  name = var.name
  vpc_id = var.vpc_id
  

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      description = ingress.value.description
      cidr_blocks = [ ingress.value.cidr_block ]
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      
      
      
    }

  }

#   dynamic "egress" {
#     for_each = var.ingress_rules

#     content {
#       description = egress.value.description
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       cidr_blocks = [egress.value.cidr_block]
#       protocol    = "tcp"
      
      
      
#     }
# }

}