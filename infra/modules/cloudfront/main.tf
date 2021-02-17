locals {
  s3-origin-prod       = "${var.environment}-s3-origin"
  logs-bucket          = "${var.bucket-name}-logs"
  cf-alias             = "${var.environment}.cdn.${var.domain}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name
  acl    = "public-read"

  tags = {
    Name = var.bucket-name
    Env  = var.environment
  }
}

# Objects that will exist in either bucket based on the env var
resource "aws_s3_bucket_object" "prod-index-html" {
  content_type = "text/plain"
  count = var.environment == "prod" ? 1 : 0
  acl    = "public-read"
  bucket = aws_s3_bucket.bucket.id
  key    = "prod-index.html"
  source = "${path.module}/files/prod-index.html"
}

resource "aws_s3_bucket_object" "beta-index-html" {
  content_type = "text/plain"
  count = var.environment == "beta" ? 1 : 0
  acl    = "public-read"
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "${path.module}/files/index.html"
}

# Logging bucket for CloudFront
resource "aws_s3_bucket" "bucket-logs" {
  acl    = "private"
  bucket = local.logs-bucket
  force_destroy = true

  tags = {
    Name = local.logs-bucket
    Env  = var.environment
  }
}

resource "aws_cloudfront_distribution" "cf" {
  aliases             = [local.cf-alias]
  enabled             = true
  default_root_object = "index.html"

  logging_config {
    bucket = aws_s3_bucket.bucket-logs.bucket_regional_domain_name
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3-origin-prod
    viewer_protocol_policy = "allow-all"

    lambda_function_association {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = var.lambda-arn
    }

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3-origin-prod

    # Edge Lambdas don't support environment variables. This seems the most impertive way to make the env var available
    # to the Lambda based on it's deployment environment
    custom_header {
      name  = "X-Env-Type"
      value = var.environment
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm-certificate-arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

}

data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "cdn" {
  name    = "${var.environment}.cdn.${var.domain}"
  records = [aws_cloudfront_distribution.cf.domain_name]
  ttl     = 60
  type    = "CNAME"
  zone_id = data.aws_route53_zone.zone.id
}