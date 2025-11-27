output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.ecr_nextgenz.repository_url
}

