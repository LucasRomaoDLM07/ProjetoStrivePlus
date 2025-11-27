###########################################
# SECURITY GROUP DO DB-HOST
###########################################

provider "aws" {
  region = var.region
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project}-db-sg"
  description = "Permite acesso MySQL somente do SG da app"
  vpc_id      = var.vpc_id

  # 3306 liberado APENAS para o SG da aplicação
  ingress {
    description     = "MySQL from application SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

ingress {
  description     = "SSH only from application/bastion SG"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_groups = [var.app_sg_id]
}

  # Saída liberada (padrão)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-db-sg"
  }
}

###########################################
# BASTION HOST (NA SUBNET PÚBLICA)
###########################################

data "aws_ami" "ubuntu_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "zabbix" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # UBUNTU
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.keypair

  associate_public_ip_address = true

  tags = {
    Name = "${var.project}-zabbix"
  }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0f9fc25dd2506cf6d" # Amazon Linux 2
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.keypair

  associate_public_ip_address = true

  tags = {
    Name = "${var.project}-bastion"
  }
}

###########################################
# DB HOST (NA SUBNET PRIVADA)
###########################################

resource "aws_instance" "db_host" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = var.db_instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  associate_public_ip_address = false
  key_name               = var.keypair

  tags = {
    Name = "${var.project}-db-host"
  }
}