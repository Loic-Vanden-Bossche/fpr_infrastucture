variable "access_key" {
  description   = "AWS access key"
  type          = string
  sensitive     = true
}

variable "secret_access_key" {
  description   = "AWS secret access key"
  type          = string
  sensitive     = true
}

variable "region" {
  description   = "Region to use for AWS resources"
  type          = string
  default       = "eu-west-3"
}

variable "docker_hub_username" {
  description   = "Docker hub username"
  type          = string
  default       = "lvandenbossche"
}

variable "docker_hub_secret" {
  description   = "Docker hub secret"
  sensitive     = true
  type          = string
}

variable "docker_hub_image_name" {
  description   = "Docker hub image name"
  type          = string
  default       = "fpr-backend"
}

variable "docker_hub_image_tag" {
  description   = "Docker hub image tag"
  type          = string
  default       = "latest"
}

variable "rds_pg_username" {
  description   = "RDS Postgres username"
  type          = string
  default       = "postgres"
}

variable "rds_pg_password" {
  description   = "RDS Postgres password"
  sensitive     = true
  type          = string
}