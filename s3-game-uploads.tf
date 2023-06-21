resource "aws_s3_bucket" "game_uploads" {
  bucket = "game-uploads"
  tags = {
    "Project"   = "FPR"
    "ManagedBy" = "Terraform"
  }
  force_destroy = true
}
