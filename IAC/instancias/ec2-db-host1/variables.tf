region      = "us-east-1"
vpc_id      = "vpc-0d076ec690fda29b4"
subnet_id   = "subnet-07821441e2d97d9ca"
key_name    = "vockey"
[ec2-user@ip-172-31-24-133 ec2-db-host]$ cat variables.tf
variable "ami_id" {
  description = "AMI ID para a instância"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.small"
}

variable "subnet_id" {
  description = "Subnet onde a EC2 será criada"
  type        = string
}

variable "security_group_id" {
  description = "Security Group da EC2"
  type        = string
}

variable "key_name" {
  description = "Nome da key pair para acesso SSH"
  type        = string
}
