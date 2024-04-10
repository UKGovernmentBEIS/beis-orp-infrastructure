data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}


variable "assume_role" {
  default = "ci"
}

variable "region" {
  default = "eu-west-2"
}


terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58"
    }
  }

  # backend "s3" {
  #   bucket         = var.bucket
  #   key            = var.key
  #   region         = var.region
  #   dynamodb_table = var.dynamodb_table
  #   encrypt        = true
  # }
}

provider "aws" {
   region = var.region
#  profile = var.tf_profile
}
