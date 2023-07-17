resource "aws_s3_bucket" "game_uploads_bucket" {
  bucket_prefix = "game-uploads"
  tags = {
    "Project"   = "FPR"
    "ManagedBy" = "Terraform"
  }
  force_destroy = true
}
