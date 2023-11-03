#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

#---------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION 
#---------------------------------------------------------------

provider "aws" {
  region  = "us-east-1"     # Region
  profile = "terraform_dev" # use your authorised profile 
}

