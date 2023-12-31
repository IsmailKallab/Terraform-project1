# -----------------------------------------------------------------------------------
# Create Multi Aviability Zone Rational Data Service (RDS)
# -----------------------------------------------------------------------------------
/*
 | --
 | -- Create two private subnet for db
 | -- Create RDS security Group
 | -- Create Two DB instance 
 | -- 
 | --
*/
resource "aws_subnet" "RDS_private" {
  count             = length(var.availability_zones)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidrs_RDS_private[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "RDS_Private_Subnet-${count.index + 1}"
  }

}

## RDS Subnet Group for Postgres
resource "aws_db_subnet_group" "db-subnet-group" {
    
  name = "${var.project}-db-subnet-group-${var.environment}"
  subnet_ids = [
    aws_subnet.RDS_private[0].id,
    aws_subnet.RDS_private[1].id,
   
  ]
  tags = {
    Name = "${var.project}-db-subnet-group-${var.environment}"
  }
}

## Security Group for RDS Postgres
resource "aws_security_group" "rds-postgres-sg" {
  name        = "${var.project}-rds-postgres-sg-${var.environment}"
  description = "Security group for RDS Postgres"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Postgres port"
    from_port       = var.rds-postgres-db-port
    to_port         = var.rds-postgres-db-port
    protocol        = "tcp"
    security_groups = [var.postgres_sg]
  }
}

## KMS Key for RDS Postgres
resource "aws_kms_key" "db_key" {
  description         = "KMS key for RDS Postgres"
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
}

## Parameter Group for RDS Postgres
resource "aws_db_parameter_group" "rds-postgres-pg" {
  name        = "${var.project}-rds-postgres-pg-${var.environment}"
  family      = "postgres14"
  description = "Custom Parameter Group for RDS Postgres"
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "immediate"
  }
  tags = {
    Name = "${var.project}-rds-postgres-pg-${var.environment}"
  }
}

## RDS DB Instance for Postgres
resource "aws_db_instance" "rds-postgres" {
  identifier                            = "${var.project}-rds-postgres-db-${var.environment}"
  engine                                = "postgres"
  engine_version                        = "14.6"
  instance_class                        = "db.t3.micro"
  allocated_storage                     = 20
  max_allocated_storage                 = 100
  storage_type                          = "gp2"
  storage_encrypted                     = true
  kms_key_id                            = aws_kms_key.db_key.arn
  username                              = var.rds-postgres-db-username
  password                              = var.rds-postgres-db-password
  port                                  = var.rds-postgres-db-port
  multi_az                              = true
  db_subnet_group_name                  = aws_db_subnet_group.db-subnet-group.id
  vpc_security_group_ids                = [aws_security_group.rds-postgres-sg.id]
  deletion_protection                   = false
  allow_major_version_upgrade           = false
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  backup_retention_period               = 30
  backup_window                         = "21:00-23:00"
  maintenance_window                    = var.rds-postgres-db-maintenance-window
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = true
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.db_key.arn
  performance_insights_retention_period = 7
  publicly_accessible                   = false
  parameter_group_name                  = aws_db_parameter_group.rds-postgres-pg.id
  skip_final_snapshot                   = false
  final_snapshot_identifier             = "${var.project}-rds-postgres-db-final-snapshot-${var.environment}"
}