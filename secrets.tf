resource "aws_secretsmanager_secret" "fpr_backend_docker_access_key" {
  name = "fpr-backend-docker-access-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "access_key_v" {
  secret_id = aws_secretsmanager_secret.fpr_backend_docker_access_key.id
  secret_string = jsonencode({
    "username" : var.docker_hub_username,
    "password" : var.docker_hub_secret
  })
}

resource "aws_vpc_endpoint" "secretsmanager_vpc_endpoint" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_default_vpc.default_vpc.id
  service_name = "com.amazonaws.${var.region}.secretsmanager"
}