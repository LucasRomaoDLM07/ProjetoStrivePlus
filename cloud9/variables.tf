# Região onde os recursos serão criados
variable "region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

# Nome do ambiente Cloud9
variable "cloud9_name" {
  description = "Nome do ambiente Cloud9"
  type        = string
  default     = "cloud9-nextgenz"
}

# Tipo de instância EC2 usada pelo Cloud9
variable "instance_type" {
  description = "Tipo da instância EC2 para o ambiente Cloud9"
  type        = string
  default     = "t3.micro"
}

# ID da Subnet onde o Cloud9 será criado
variable "subnet_id" {
  description = "ID da subnet onde o Cloud9 será provisionado"
  type        = string
}

# Permite definir a VPC se quiser usar em outputs ou integrações futuras
variable "vpc_id" {
  description = "ID da VPC associada ao ambiente"
  type        = string
}

# Permite definir o owner tag (identificação do projeto)
variable "owner" {
  description = "Identificação do dono/projeto do ambiente"
  type        = string
  default     = "NextGenZ"
}
