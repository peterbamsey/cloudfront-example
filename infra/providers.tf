provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}