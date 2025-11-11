output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.ecr_nextgenz.repository_url
}
[ec2-user@ip-172-31-24-133 ecr]$ cat provider.tf
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
