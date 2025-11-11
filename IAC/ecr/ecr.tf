#############################################
# ECR - Repositório de Imagens Docker
# Padrão: ecr-nextgenz
#############################################

resource "aws_ecr_repository" "ecr_nextgenz" {
  name                 = "ecr-nextgenz"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = "Nextgenz"
    ManagedBy = "Terraform"
  }
}

#############################################
# Policy pública opcional (caso queira permitir
# pull de imagens específicas por outro serviço)
#############################################

# resource "aws_ecr_repository_policy" "ecr_nextgenz_policy" {
#   repository = aws_ecr_repository.ecr_nextgenz.name
#
#   policy = jsonencode({
#     Version = "2008-10-17",
#     Statement = [
#       {
#         Sid    = "AllowPull",
#         Effect = "Allow",
#         Principal = "*",
#         Action = [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability"
#         ]
#       }
#     ]
#   })
# }
