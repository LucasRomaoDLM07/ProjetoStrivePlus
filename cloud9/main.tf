# --- CLOUD9 ---
resource "aws_cloud9_environment_ec2" "cloud9_nextgenz" {
  name                        = var.cloud9_name
  instance_type               = var.instance_type
  image_id                    = "amazonlinux-2-x86_64"
  
  # AQUI ESTÁ O TRUQUE: Usa a variável que vai pedir o ID no terminal
  subnet_id                   = var.subnet_id 
  
  automatic_stop_time_minutes = 30

  tags = {
    Project     = "nextgenz"
    Environment = "dev"
  }
}