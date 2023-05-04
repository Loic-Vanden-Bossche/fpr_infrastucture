data "aws_route53_zone" "public" {
  name         = "flash-player-revival.fr"
  private_zone = false
}

resource "aws_acm_certificate" "api-cert" {
  domain_name       = "api.flash-player-revival.fr"
  validation_method = "DNS"
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api-cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

resource "aws_route53_record" "api" {
  name    = aws_acm_certificate.api-cert.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_alb.fpr_backend_load_balancer.dns_name
    zone_id                = aws_alb.fpr_backend_load_balancer.zone_id
    evaluate_target_health = false
  }
}