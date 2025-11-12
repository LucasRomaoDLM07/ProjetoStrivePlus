variable "aws_region" {
  description = "Região da AWS para implantar os recursos."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC onde o SG será criado."
  type        = string
}

variable "my_ip" {
  description = "Seu IP público com /32 para acesso SSH."
  type        = string
  default     = "54.174.120.33/32" # altere se necessário
}
