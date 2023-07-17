# Backend
resource "aws_acm_certificate" "public-api-cert" {
  domain_name       = "${var.api_subdomain_name}.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.public-api-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

# Frontend
resource "aws_acm_certificate" "public-cert-frontend" {
  provider          = aws.virginia
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "frontend" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.public-cert-frontend.arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_validation : record.fqdn]
}

# Medias
resource "aws_acm_certificate" "public-cert-medias" {
  provider          = aws.virginia
  domain_name       = "${var.medias_subdomain_name}.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "medias" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.public-cert-medias.arn
  validation_record_fqdns = [for record in aws_route53_record.medias_validation : record.fqdn]
}