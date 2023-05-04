output "app_url" {
  value = aws_alb.fpr_backend_load_balancer.dns_name
}

output "database_url" {
  value = aws_db_instance.fpr_backend_db.address
}