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

  backend "s3" {
    bucket         = "beis-state-dev"
    key            = "beis-state-dev.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "beis-orp-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
#  profile = var.tf_profile
}
