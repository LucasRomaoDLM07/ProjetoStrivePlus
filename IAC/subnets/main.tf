# --- Subnet Pública ---
resource "aws_subnet" "public_2" {
  vpc_id                  = "vpc-0d076ec690fda29b4"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# --- Subnet Privada ---
resource "aws_subnet" "private_2" {
  vpc_id            = "vpc-0d076ec690fda29b4"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# --- Elastic IP ---
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

# --- NAT Gateway ---
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_2.id
  tags = {
    Name = "nat-gateway"
  }
}

# --- Route Table da Subnet Privada ---
resource "aws_route_table" "private_rt_2" {
  vpc_id = "vpc-0d076ec690fda29b4"
  tags = {
    Name = "private-rt-2"
  }
}

# --- Rota da Subnet Privada via NAT ---
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

# --- Associação da Subnet Privada ---
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_2.id
}
