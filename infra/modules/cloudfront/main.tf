locals {
  s3-origin-prod = "${var.environment}-s3-origin"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name
  acl    = "private"

  tags = {
    Name = var.bucket-name
    Env  = var.environment
  }
}

resource "aws_cloudfront_distribution" "cf" {
  enabled = true

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3-origin-prod
    viewer_protocol_policy = "allow-all"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = var.lambda-arn
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
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}