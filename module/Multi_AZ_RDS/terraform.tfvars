

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

# VPC_ID

vpc_id = ""

# Postgres Security group
postgres_sg = []