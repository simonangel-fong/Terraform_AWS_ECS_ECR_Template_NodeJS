# #################################
# ECR
# #################################
resource "aws_ecr_repository" "ecr_repo" {
  name         = "${var.app_name}-ecr-repo"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# #################################
# output
# #################################
output "ecr_repo_url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}
