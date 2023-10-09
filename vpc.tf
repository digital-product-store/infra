# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main"
  }
}

# Subnets
## Public
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.public_subnet_1_az

  tags = {
    "Name"                        = "public-subnet-1"
    "kubernetes.io/role/elb"      = "1"
    "kubernetes.io/cluster/store" = "owned"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.public_subnet_2_az

  tags = {
    "Name"                        = "public-subnet-2"
    "kubernetes.io/role/elb"      = "1"
    "kubernetes.io/cluster/store" = "owned"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = var.public_subnet_3_az

  tags = {
    "Name" = "public-subnet-3"
  }
}

## Private
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_subnet_1_az

  tags = {
    "Name"                            = "private-subnet-1-eks-owned"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/store"     = "owned"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_subnet_2_az

  tags = {
    "Name"                            = "private-subnet-2-eks-owned"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/store"     = "owned"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.private_subnet_3_az

  tags = {
    "Name" = "private-subnet-3"
  }
}

resource "aws_subnet" "private_subnet_4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_4_cidr
  availability_zone = var.private_subnet_4_az

  tags = {
    "Name" = "private-subnet-4"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_public_ip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "main_natgw" {
  allocation_id = aws_eip.nat_public_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "main-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

# Route Tables and Associations
## Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_natgw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

## Associations
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_4" {
  subnet_id      = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private.id
}
