data "aws_route53_zone" "public" {
  name         = var.domain_name
  private_zone = false
}

# Backend
resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.public-api-cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public.zone_id
}

resource "aws_route53_record" "api" {
  name    = aws_acm_certificate.public-api-cert.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_alb.fpr_backend_load_balancer.dns_name
    zone_id                = aws_alb.fpr_backend_load_balancer.zone_id
    evaluate_target_health = false
  }
}

# Fronted
resource "aws_route53_record" "fronted_validation" {
  provider = aws.virginia
  for_each = {
    for dvo in aws_acm_certificate.public-cert-fronted.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public.zone_id
}

resource "aws_route53_record" "fronted" {
  provider = aws.virginia
  name     = aws_acm_certificate.public-cert-fronted.domain_name
  type     = "A"
  zone_id  = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_cloudfront_distribution.cf_dist.domain_name
    zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
    evaluate_target_health = false
  }
}