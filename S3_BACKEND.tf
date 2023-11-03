# ------------------------------------------------------------------------------
# TO CONFIGURE S3 BACKEND FOR YOUR TERRAFORM STATE FILE 
# AND TO SAVE THE TERRAFORM STATE FILE OUTSIDE YOUR MACHINE 
# FOR COLLAPRATIVE TEAM TO WORK REMOTLY
# ADD VERSSONING TO S3 
# ENCYPT THE OBJECT
# ------------------------------------------------------------------------------

/*
 | --
 | -- save Terraform state file on s3 not in local machine and encypted
 | -- lockId using DynamoDB to lock concurrent accsses to terraform state file
 | -- But first you have to create DynamoDB LockID
 | -- 
 | --
*/

# terraform {
#     backend "s3" {
#     encrypt        = true
#     bucket         = "790174187069-terraform-state"
#     key            = "project1/terraform.tfstate"
#     region         = "us-east-1"
#     profile        = "terraform_dev"   # provide your aws profile 
#     dynamodb_table = "terraform-lock"
#   }
# }


/*
 | --
 | -- use terraform init -upgrade
 | -- then terraform plan after congfiguring s3 backend to sync the terraform state file
 | -- But first you have to create DynamoDB LockID
 | -- on your local machine to prevent fork state and error before
 | -- destroing your infrastructure
 | -- 
*/




