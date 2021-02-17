# Create Certificate
resource "aws_acm_certificate" "cert" {
  domain_name = var.domain
  subject_alternative_names = [
    "*.${var.domain}",
    "${var.sub-domain}.${var.domain}",
    "*.${var.sub-domain}.${var.domain}"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Use Route 53 records to validate the certificate automatically
data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}