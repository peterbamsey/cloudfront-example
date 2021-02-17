locals {
  bucket-name     = "${var.environment}.cdn.${var.domain}"
  fallback-domain = var.environment == "prod" ? "" : "prod.cdn.${var.domain}"
}

module "acm" {
  source      = "./modules/acm"
  domain      = var.domain
  environment = var.environment
  sub-domain  = "cdn"
}

module "cloudfront" {
  source = "./modules/cloudfront"

  acm-certificate-arn = module.acm.acm-certificate-arn
  bucket-name         = local.bucket-name
  domain              = var.domain
  environment         = var.environment
  lambda-arn          = module.lambda.lambda-arn
}

module "lambda" {
  source          = "./modules/lambda"
  account-id      = data.aws_caller_identity.id.account_id
  environment     = var.environment
  fallback-domain = local.bucket-name
  function-name   = "cloudfront-example"
  region          = var.region
}

data "aws_caller_identity" "id" {}