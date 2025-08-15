# #################################
# ECR
# #################################
resource "aws_ecr_repository" "ecr_repo_myapp" {
  name = "ecr_repo_myapp"
}

# #################################
# output
# #################################
output "ecr_repo_myapp_url" {
  value = aws_ecr_repository.ecr_repo_myapp.repository_url
}
