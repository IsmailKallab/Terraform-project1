# ------------------------------------------------------------------------------
# CREATE ENCRYPTED EBS-BACKED EC2 IN PRIVATE SUBNET IN US-EAST-1A & US-EAST-1B
# ------------------------------------------------------------------------------


resource "aws_instance" "web" {

  depends_on        = [aws_nat_gateway.ngw]
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  count             = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  subnet_id         = aws_subnet.private[count.index].id
  security_groups   = [module.security_group_PS.Private_sg_id]
  user_data         = var.user_data_scripts[count.index]
  root_block_device {
    encrypted             = true
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }
  tags = {
    Name = "private-${var.instance_name[count.index]}"
  }
}

