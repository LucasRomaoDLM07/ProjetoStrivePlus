output "ec2_db_host_private_ip" {
  description = "IP privado da instância DB Host"
  value       = aws_instance.db_host.private_ip
}

output "ec2_db_host_id" {
  description = "ID da instância DB Host"
  value       = aws_instance.db_host.id
}
