output "api_url" {
  value = "https://${aws_acm_certificate.public-api-cert.domain_name}/actuator/health"
}

output "database_url" {
  value = aws_db_instance.fpr_backend_db.address
}