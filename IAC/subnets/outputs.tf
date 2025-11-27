output "public_subnet_id-1a" {
  value = aws_subnet.public_1a.id
}

output "public_subnet_id-1b" {
  value = aws_subnet.public_1b.id
}

output "private_subnet_id-1a" {
  value = aws_subnet.private_1a.id
}

output "private_subnet_id-1b" {
  value = aws_subnet.private_1b.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.natgw.id
}
