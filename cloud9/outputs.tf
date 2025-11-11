output "cloud9_environment_id" {
  description = "ID do ambiente Cloud9"
  value       = aws_cloud9_environment_ec2.cloud9_nextgenz.id
}

output "cloud9_url" {
  description = "URL do ambiente Cloud9"
  value       = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.cloud9_nextgenz.id}"
}
