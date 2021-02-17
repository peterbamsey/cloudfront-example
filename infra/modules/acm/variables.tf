variable "domain" {
  description = "The root domain of the e.g bamsey.net"
  type        = string
}

variable "environment" {
  description = "The environment that the resources live in e.g prod or beta"
  type        = string
}

variable "sub-domain" {
  description = "The left part of the DNS name"
  type        = string
}
