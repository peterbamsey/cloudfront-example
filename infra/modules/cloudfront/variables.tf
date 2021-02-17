variable "bucket-name" {
  description = "The S3 bucket name"
  type        = string
}

variable "acm-certificate-arn" {
  description = "The ARN of the ACM certificate to associate with the Cloudfront dist"
  type        = string
}

variable "domain" {
  description = "The root domain of the e.g bamsey.net"
  type        = string
}

variable "environment" {
  description = "The environment that the resources live in e.g prod or beta"
  type        = string
}

variable "lambda-arn" {
  description = "The ARN of the Lambda to associate with the CloudFront dist"
  type        = string
}