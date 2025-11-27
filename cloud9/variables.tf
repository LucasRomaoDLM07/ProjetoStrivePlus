variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# --- ESTA É A VARIÁVEL QUE VAI PEDIR O INPUT NO TERMINAL ---
variable "subnet_id" {
  description = "Cole aqui o ID da Subnet (pública) onde o Cloud9 será criado (ex: subnet-0abc...)"
  type        = string
  # Sem 'default', para forçar a pergunta
}

variable "cloud9_name" {
  description = "Nome do ambiente Cloud9"
  type        = string
  default     = "cloud9-nextgenz"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}