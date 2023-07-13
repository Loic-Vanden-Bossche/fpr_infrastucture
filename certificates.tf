# Backend
resource "aws_acm_certificate" "public-api-cert" {
  domain_name       = "api.flash-player-revival.net"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.public-api-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

# Fronted
resource "aws_acm_certificate" "public-cert-fronted" {
  provider          = aws.virginia
  domain_name       = "flash-player-revival.net"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "fronted" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.public-cert-fronted.arn
  validation_record_fqdns = [for record in aws_route53_record.fronted_validation : record.fqdn]
}
