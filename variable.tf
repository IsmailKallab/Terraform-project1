# Vpc Cidr Block
variable "vpc_cidr_block" {
  type        = string
  description = "The IP range to use for the Project1 VPC"
  default     = "10.0.0.0/16"
}

# Spicify AWS Region
variable "region" {
  default = "us-east-1"
}

# aviability zone for us-east-1 region to assign 
variable "availability_zones" {
  type        = list(any)
  description = "AZs in this region to use"
  default     = ["us-east-1a", "us-east-1b"]

}

# cidr block for public subnet
variable "subnet_cidrs_public" {
  type        = list(any)
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]

}



# cidr block for private subnet

variable "subnet_cidrs_private" {
  type        = list(any)
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["10.0.100.0/24", "10.0.200.0/24"]

}

## Allow all traffic 
variable "all_trafic_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Allow all traffic"

}

# Amazon Linux 2023 AMI in us-east-1
variable "ami" {
  default = "ami-01eccbf80522b562b"
}

# type of ec2 instance
variable "instance_type" {
  default = "t2.micro"
}

# key-pair 
variable "key_name" {
  default = "mkN.V"

}

# to use user data and install apache server inside ec2


variable "user_data_scripts" {
  type = list(string)
  default = [
    "#!/bin/bash\nyum update -y\nyum install httpd -y\nservice httpd start\nchkconfig httpd on\necho 'This Server *1* in AWS Region US-EAST-1 in AZ US-EAST-1A' > /var/www/html/index.html",
    "#!/bin/bash\nyum update -y\nyum install httpd -y\nservice httpd start\nchkconfig httpd on\necho 'This Server *2* in AWS Region US-EAST-1 in AZ US-EAST-1B' > /var/www/html/index.html",
  ]
}

variable "user_data_scripts_base64" {
  type = list(string)
  default = [
    "IyEvYmluL2Jhc2hcbnl1bSB1cGRhdGUgLXlcbnl1bSBpbnN0YWxsIGh0dHBkIC15XG5zZXJ2aWNlIGh0dHBkIHN0YXJ0XG5jaGtjb25maWcgaHR0cGQgb25cbmVjaG8gJ1RoaXMgU2VydmVyICoxKiBpbiBBV1MgUmVnaW9uIFVTLUVBU1QtMSBpbiBBWiBVUy1FQVNULTFBJyA+IC92YXIvd3d3L2h0bWwvaW5kZXguaHRtbA==",
    "IyEvYmluL2Jhc2hcbnl1bSB1cGRhdGUgLXlcbnl1bSBpbnN0YWxsIGh0dHBkIC15XG5zZXJ2aWNlIGh0dHBkIHN0YXJ0XG5jaGtjb25maWcgaHR0cGQgb25cbmVjaG8gJ1RoaXMgU2VydmVyICoyKiBpbiBBV1MgUmVnaW9uIFVTLUVBU1QtMSBpbiBBWiBVUy1FQVNULTFCJyA+IC92YXIvd3d3L2h0bWwvaW5kZXguaHRtbA==",
  ]
}

# Private instance tags 
variable "instance_name" {
  type    = list(string)
  default = ["instance-1", "instance-2"]

}