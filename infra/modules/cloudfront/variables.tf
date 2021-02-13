variable "bucket-name" {
  description = "The S3 bucket name"
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