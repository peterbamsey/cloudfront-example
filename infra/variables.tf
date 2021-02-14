variable "domain" {
  description = "The root domain of the e.g bamsey.net"
  type        = string
}

variable "environment" {
  description = "The environment the resources will be deployed to e.g prod or beta"
  type        = string
}

variable "region" {
  description = "The AWS region which the resources are deployed in"
  type        = string
}