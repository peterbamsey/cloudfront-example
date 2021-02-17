variable "account-id" {
  description = "The AWS account ID"
  type        = string
}

variable "environment" {
  description = "The environment that the resources live in e.g prod or beta"
  type        = string
}

variable "fallback-domain" {
  description = "The domain to flal back to if the requested bucket key is not found"
  type        = string
}

variable "function-name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}
