output "public_subnet_id" {
  value = aws_subnet.public_2.id
}

output "private_subnet_id" {
  value = aws_subnet.private_2.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.natgw.id
}
