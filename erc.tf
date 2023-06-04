resource "aws_ecr_repository" "fpr_games_repository" {
  name                 = "fpr-games-repository"
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = false
  }
}