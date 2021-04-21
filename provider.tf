provider "aws" {
  region = var.region
  shared_credentials_file = "/Users/sethmoyes/.aws/labappcreds"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}