variable "region" {
  type        = string
  description = "AWS region (ex: us-east-1)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID onde a infra será provisionada"
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de subnets públicas (2 recommended)"
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de subnets privadas (2 recommended)"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "Tipo de instância para as EC2 do cluster"
}

variable "app_image" {
  type        = string
  default     = "448506098935.dkr.ecr.us-east-1.amazonaws.com/ecr-nextgenz:latest"
  description = "URI da imagem no ECR (com tag)"
}

variable "db_host" {
  type        = string
  default     = "10.0.2.159"
  description = "Endereço (privado) do DB MariaDB"
}