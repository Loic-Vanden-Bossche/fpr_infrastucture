terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.65.0"
    }
    docker = {
      source    = "kreuzwerker/docker"
      version   = "3.0.2"
    }
  }
}

provider "aws" {
  region        = var.region
  access_key    = var.access_key
  secret_key    = var.secret_access_key
}