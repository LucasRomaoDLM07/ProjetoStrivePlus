provider "aws" {
  region = "us-east-1"
}

# Referencia recursos EXISTENTES
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["vpc-app"]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["pubic-subnet-1"]
  }
}

data "aws_security_group" "selected" {
  filter {
    name   = "tag:Name"
    values = ["default-lab-sg"]
  }
}

# Instância EC2 do banco
resource "aws_instance" "db_host" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2
  instance_type = "t3.small"

  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [data.aws_security_group.selected.id]

   associate_public_ip_address = true

  tags = {
    Name = "db-host"
    Environment = "prod"
  }
}

# Saída dos detalhes
output "ec2_db_host_details" {
  value = {
    instance_id = aws_instance.db_host.id
    subnet_id   = aws_instance.db_host.subnet_id
    vpc_id      = data.aws_vpc.selected.id
    sg_id       = data.aws_security_group.selected.id
    private_ip  = aws_instance.db_host.private_ip
  }
}
