resource "aws_security_group" "default_lab_sg" {
  name        = "default-lab-sg"
  description = "Security Group padrao para laboratorio"
  vpc_id      = var.vpc_id

  # Regras de saída - tudo liberado
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH liberado apenas pro seu IP
  ingress {
    description = "SSH acesso restrito"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # ICMP (ping)
  ingress {
    description = "Permitir ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "default-lab-sg"
    ManagedBy = "Terraform"
  }
}

output "lab_sg_id" {
  description = "ID do Security Group criado"
  value       = aws_security_group.default_lab_sg.id
}
