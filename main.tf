# ========================= #
# ===== Main Executor ===== #
# ========================= #
# Purpose
# Manage all instantiated modules and providers
#
# Notes
# This module manager gives a holistic view on the environment being deployed through IAC. It provides documentation,
# clear and concise variables, and is easy to read for the purposes of understanding the code in the repo.

locals {
  common_tags = {
    Infra = "Lambda_Visitor_Query"
    Owner = "benwagrez@gmail.com"
  }
}

#############################
###### Provider Config ######
#############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.region
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}


#############################
###### Module Manager #######
#############################
# Below module dependencies are listed #
# ------------------------------------ #
# lambda_deployment | Dependent on an application load balancer with access logs enabled


module "lambda_deployment" {
  source                  = "./deploy_lambda"

  log_bucket              = var.log_bucket
  log_bucket_location     = var.log_bucket_location
  athena_table_name       = var.athena_table_name
  ses_email               = var.ses_email
  common_tags             = local.common_tags
}
