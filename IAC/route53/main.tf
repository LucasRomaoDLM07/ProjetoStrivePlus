terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 5.0"
}
}
}
provider "aws" {
region = "us-east-1"
}
# --- Hosted Zone ---
resource "aws_route53_zone" "main" {
name = "nextgenz.com.br"
}
# --- Registro A para subdomínio (www) ---
resource "aws_route53_record" "app_record" {
zone_id = aws_route53_zone.main.zone_id
name = "www.nextgenz.com.br"
type = "A"
alias {
name = var.alb_dns_name
zone_id = var.alb_zone_id
evaluate_target_health = true
}
}
# --- Registro A para domínio raiz ---
resource "aws_route53_record" "root_record" {
zone_id = aws_route53_zone.main.zone_id
name = "nextgenz.com.br"
type = "A"
alias {
name = var.alb_dns_name
zone_id = var.alb_zone_id
evaluate_target_health = true
}
}