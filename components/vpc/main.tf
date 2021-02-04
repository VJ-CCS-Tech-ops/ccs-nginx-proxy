# Create the initial nginx vpc
resource "aws_vpc" "nginx_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = var.nginx_vpc_name
  }
}

# Create an Internet Gateway to use within the nginx VPC
resource "aws_internet_gateway" "nginx_vpc_internet_gateway" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = var.nginx_igw_name
  }
}

# Create 2 public and 2 private subnets for the nginx VPC (Multi-AZ)
resource "aws_subnet" "nginx_public_subnet_a" {
  availability_zone       = var.public_subnet_az_a
  cidr_block              = var.nginx_public_subnet_a_cidr_block
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.nginx_vpc.id

  tags = {
    Name = var.nginx_public_subnet_a_name
  }
}

resource "aws_subnet" "nginx_public_subnet_b" {
  availability_zone       = var.public_subnet_az_b
  cidr_block              = var.nginx_public_subnet_b_cidr_block
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.nginx_vpc.id

  tags = {
    Name = var.nginx_public_subnet_b_name
  }
}

resource "aws_subnet" "nginx_private_subnet_a" {
  availability_zone       = var.private_subnet_az_a
  cidr_block              = var.nginx_private_subnet_a_cidr_block
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.nginx_vpc.id

  tags = {
    Name = var.nginx_private_subnet_a_name
  }
}

resource "aws_subnet" "nginx_private_subnet_b" {
  availability_zone       = var.private_subnet_az_b
  cidr_block              = var.nginx_private_subnet_b_cidr_block
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.nginx_vpc.id

  tags = {
    Name = var.nginx_private_subnet_b_name
  }
}

# Create EIPs to be consumed by NAT Gateway(s)
resource "aws_eip" "nat_gateway_public_subnet_a_eip" {
  vpc = true
}

resource "aws_eip" "nat_gateway_public_subnet_b_eip" {
  vpc = true
}

# Create NAT Gateways to be allocated EIP instances, connecting to public subnets
resource "aws_nat_gateway" "nat_gateway_public_subnet_a" {
  allocation_id = aws_eip.nat_gateway_public_subnet_a_eip.id
  subnet_id     = aws_subnet.nginx_public_subnet_a.id

  tags = {
    Name = "${aws_vpc.nginx_vpc.tags.Name}_nat_gateway_a"
  }
}

resource "aws_nat_gateway" "nat_gateway_public_subnet_b" {
  allocation_id = aws_eip.nat_gateway_public_subnet_b_eip.id
  subnet_id     = aws_subnet.nginx_public_subnet_b.id

  tags = {
    Name = "${aws_vpc.nginx_vpc.tags.Name}_nat_gateway_b"
  }
}

# Create Public Route Table
resource "aws_route_table" "nginx_vpc_public_route_table" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "${aws_vpc.nginx_vpc.tags.Name}_public_route_table"
  }
}

# Add Route for Public Route Table to allow access to IGW
resource "aws_route" "nginx_vpc_public_route_table_to_igw_route" {
  destination_cidr_block = var.nginx_public_route_table_cidr_block
  gateway_id             = aws_internet_gateway.nginx_vpc_internet_gateway.id
  route_table_id         = aws_route_table.nginx_vpc_public_route_table.id
}

# Associate Public Route Table with Public Subnet A and B
resource "aws_route_table_association" "nginx_vpc_public_route_table_to_pub_subnet_a_association" {
  route_table_id = aws_route_table.nginx_vpc_public_route_table.id
  subnet_id      = aws_subnet.nginx_public_subnet_a.id
}

resource "aws_route_table_association" "nginx_vpc_public_route_table_to_pub_subnet_b_association" {
  route_table_id = aws_route_table.nginx_vpc_public_route_table.id
  subnet_id      = aws_subnet.nginx_public_subnet_b.id
}

# Create Private Route Table A
resource "aws_route_table" "nginx_vpc_private_route_table_a" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "${aws_vpc.nginx_vpc.tags.Name}_private_route_table_a"
  }
}

resource "aws_route" "nginx_vpc_private_route_table_a_to_igw_route" {
  destination_cidr_block = var.nginx_public_route_table_cidr_block
  route_table_id         = aws_route_table.nginx_vpc_private_route_table_a.id
  gateway_id             = aws_internet_gateway.nginx_vpc_internet_gateway.id
}

# Associate Private Route Table A with Subnet A
resource "aws_route_table_association" "nginx_vpc_private_route_table_a_to_priv_subnet_a_association" {
  route_table_id = aws_route_table.nginx_vpc_private_route_table_a.id
  subnet_id      = aws_subnet.nginx_private_subnet_a.id
}

# Create Private Route Table B
resource "aws_route_table" "nginx_vpc_private_route_table_b" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "${aws_vpc.nginx_vpc.tags.Name}_private_route_table_b"
  }
}

resource "aws_route" "nginx_vpc_private_route_table_b_to_igw_route" {
  destination_cidr_block = var.nginx_public_route_table_cidr_block
  route_table_id         = aws_route_table.nginx_vpc_private_route_table_b.id
  gateway_id             = aws_internet_gateway.nginx_vpc_internet_gateway.id
}

# Associate Private Route Table B with Subnet B
resource "aws_route_table_association" "nginx_vpc_private_route_table_b_to_priv_subnet_a_association" {
  route_table_id = aws_route_table.nginx_vpc_private_route_table_b.id
  subnet_id      = aws_subnet.nginx_private_subnet_b.id
}
