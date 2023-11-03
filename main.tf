######################################################
#                                                    #  
# DEPLOYING A HIGHLY AVAILABLE INFRASTRUCTURE IN AWS # 
#                                                    #
######################################################

# ------------------------------------------------------------------------------
# CREATE A VPV WITH CIDR_BLOCK : 10.0.0.0/16
# ------------------------------------------------------------------------------

resource "aws_vpc" "project1" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Project1"
  }
}


# ------------------------------------------------------------------------------
# CREATE PUBLIC SUBNET IN US-EAST-1A & US-EAST-1B
# ------------------------------------------------------------------------------

# create public subnet using Length function depend on subnet_cirs_public variable numbers

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.project1.id
  cidr_block        = var.subnet_cidrs_public[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "Public_Subnet-${count.index + 1}"
  }

}


# create route table for vpv "project1" 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project1.id

  # route the tarffic to the internet for two buplic subnet 
  route {
    cidr_block = var.all_trafic_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route"
  }
}

resource "aws_main_route_table_association" "default_route" {
  vpc_id         = aws_vpc.project1.id
  route_table_id = aws_route_table.public.id
}

# associate route table to eache subnet

resource "aws_route_table_association" "public" {
  count = length(var.subnet_cidrs_public)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id

}

# attached internet gatewat to a project vpc for aws_route_table_public 

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project1.id
  tags = {
    Name = "public_subnet_internet"
  }
}




# ------------------------------------------------------------------------------
# CREATE PRIVATE SUBNET IN US-EAST-1A & US-EAST-1B
# ------------------------------------------------------------------------------

# create private subnet using Length function depend on subnet_cirs_public variable numbers

resource "aws_subnet" "private" {
  count             = length(var.subnet_cidrs_private)
  vpc_id            = aws_vpc.project1.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "Private_Subnet-${count.index + 1}"
  }

}

# create route table for vpv "project1" 

resource "aws_route_table" "private" {
  count  = length(var.subnet_cidrs_private)
  vpc_id = aws_vpc.project1.id

  /*
 | --
 | -- Adjust the private subnets rouete tables to route the updated traffic though
 | -- the Nat Gateway
 | --
*/

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }



  tags = {
    Name = "Private_route-${count.index + 1}"
  }
}


# associate route table to eache private subnet

resource "aws_route_table_association" "private" {
  count          = length(var.subnet_cidrs_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index) #The reason is that you will have as many route tables as your private subnets.h

}



# Recall WEBSG  module to create security groups for  the instance in private subnet

module "security_group_PS" {
  source = "./module/SG"
  name   = "WebSG"
  vpc_id = aws_vpc.project1.id


}


# -----------------------------------------------------------------------------------
# CREATE NAT GATEWAY FOR TWO PUBLIC SUBNETS
# -----------------------------------------------------------------------------------
#
# first we have to create two elastic ip to assign it to nat gateway 

resource "aws_eip" "nat" {
  count = 2
  vpc   = true
  tags = {
    Name = "NGW_eip-${count.index + 1}"
  }
}

# assign the EIP to two public nat gateway inside two public subnet to send 
# private subnet traffic to internet 

resource "aws_nat_gateway" "ngw" {

  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "public_gw_NAT-${count.index + 1}"
  }
}



# -----------------------------------------------------------------------------------
# CRAETE TARGET GROUP FOR APPLICATION INSTANCE LOCATED IN PRIVATE SUBNET
# -----------------------------------------------------------------------------------


resource "aws_lb_target_group" "webTG" {
  name     = "webTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project1.id
}

resource "aws_lb_target_group_attachment" "webTG" {
  count            = 2
  target_group_arn = aws_lb_target_group.webTG.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# --------------------------------------------------------------------------------------------------------
# CRAETE APPLICATION LOAD BALANCER IN PUBLIC SUBNET TO ACCSSES THE PRIVATE INSTANCE THROUGH LOAD BALANCER 
# --------------------------------------------------------------------------------------------------------
#
# Create security group to ALB  
#

resource "aws_lb" "application" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = ["${module.ALBSG.ALB_security_groups}"]
  /*
 | --
 | -- if you enable the deletion protection for loadbalancer 
 | -- then you cant destroy it and you will face a problem with removing 
 | -- inernet gate way also 
 | --
*/

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

/*
 | --
 | -- Create Lister to ALB to A listener is a process that checks for connection
 | -- requests using the port and protocol you configure.
 | -- The rules that you define for a listener determine how the load balancer routes 
 | -- requests to its registered targets. 
 | --
*/
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.application.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webTG.arn
  }
}



/*
 | --
 | -- Adjust the security group of the web/app instance to allow inbound traffic 
 | -- only from the application load balance security group as a source
 | -- 
 | --
*/
# but first we need to create security group for ALB_SG
# call the ALBSG module 

module "ALBSG" {
  vpc_id = aws_vpc.project1.id
  source = "./module/ALBSG"
  name   = "ALBSG"
}


data "aws_security_group" "ALBSG" {
  id = module.ALBSG.ALB_security_groups
}

# Adjust the ALBSG to accsses the private instance just from ALB_security_group by modifing output to WebSG
resource "aws_security_group_rule" "ALB_egress_to_WebSG" {
  type                     = "egress"
  to_port                  = 80
  protocol                 = "tcp"
  from_port                = 80
  security_group_id        = data.aws_security_group.ALBSG.id
  source_security_group_id = module.security_group_PS.Private_sg_id

}

data "aws_security_group" "WEBSG" {
  id = module.security_group_PS.Private_sg_id
}

# Allow to recive traffic just from ALBSG "HTTP"

resource "aws_security_group_rule" "WebSG_ingress_ALBSG" {
  type                     = "ingress"
  to_port                  = 80
  protocol                 = "tcp"
  from_port                = 80
  security_group_id        = data.aws_security_group.WEBSG.id
  source_security_group_id = module.ALBSG.ALB_security_groups

}


#-------------------------------------------
# Recall Multi-RDS Module 
#-------------------------------------------
/*
module "RDS" {
  source = "./module/Multi_AZ_RDS"
  vpc_id = aws_vpc.project1.id
  ## Project Variables
  region      = "us-east-1"
  project     = "project1"
  environment = "dev"

  ## RDS Variables as terrafor.tfvars

  rds-postgres-db-username           = "dbusername"
  rds-postgres-db-password           = "dbpassword"
  rds-postgres-db-port               = 5432
  rds-postgres-db-name               = "dbname"
  rds-postgres-db-maintenance-window = "Sun:00:00-Sun:03:00"

  # rds aviability zone 
  availability_zones       = ["us-east-1a", "us-east-1b"]
  subnet_cidrs_RDS_private = ["10.0.30.0/24", "10.0.40.0/24"]
  ## Security group for RDS
  postgres_sg = module.security_group_PS.Private_sg_id
}
*/
# ------------------------------------------------------------------------------
# BRING S3 MODULE TO MAIN  To Create unique S3 bucket
# ------------------------------------------------------------------------------

# module "s3_module" {
#   source = "./module/S3"
# }

# ------------------------------------------------------------------------------
# BRING DYNAMODB LOCKID MODULE TO MAIN FILE 
# ------------------------------------------------------------------------------

# module "DynamoDB_LockID" {
#   source = "./module/DynamoDB_LockID"
#   depends_on = [ module.s3_module ]   
# }



