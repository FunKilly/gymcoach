terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
  backend "s3" {
    region         = "eu-central-1"
  }
}
# Configure the AWS Provider
provider "aws" {
  region = var.primary_region
}


data "terraform_remote_state" "first_configuration" {
  backend = "s3"
  config = {
    bucket         = var.BACKEND_BUCKET_NAME
    key            = var.BACKEND_KEY
    region         = "eu-central-1"
  }
}
