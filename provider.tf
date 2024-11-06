# 'provider.tf'

provider "aws" {
  region = var.CUSTOM_AWS_REGION
}

variable "CUSTOM_AWS_REGION" {
  description = "The AWS region to deploy resources in"
}

variable "aws_account_id" {
  description = "The AWS Account ID"
}
