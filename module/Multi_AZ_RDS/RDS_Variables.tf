
## Project Varaible 

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

## RDS Variables

variable "rds-postgres-db-username" {
  type = string
  sensitive = true
}

variable "rds-postgres-db-password" {
  type = string
  # sensitive = true
}

variable "rds-postgres-db-name" {
  type = string
}

variable "rds-postgres-db-port" {
  type = number
}

variable "rds-postgres-db-maintenance-window" {
  type = string
}

# aviability zone for us-east-1 region to assign 
variable "availability_zones" {
  type        = list(any)
  description = "AZs in this region to use"

}
variable "subnet_cidrs_RDS_private" {
  type        = list(any)
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"

}

variable "vpc_id" {
  type = string

}

variable "postgres_sg" {
  type = string

}