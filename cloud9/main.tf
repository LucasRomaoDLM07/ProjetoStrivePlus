# CLOUD9 - Ambiente de Desenvolvimento
resource "aws_cloud9_environment_ec2" "cloud9_nextgenz" {
  name                        = "cloud9-nextgenz"
  instance_type               = "t3.micro"
  image_id                    = "amazonlinux-2-x86_64"
  automatic_stop_time_minutes = 30

  tags = {
    Project     = "nextgenz"
    Environment = "dev"
  }

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
}
