# ##############################
# VPC
# ##############################
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# ##############################
# Subnet
# ##############################
resource "aws_subnet" "main_subnet_public_a" {
  vpc_id                  = aws_vpc.app_vpc.id
  availability_zone       = "${var.aws_region}a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Ensure instances get public IPs

  tags = {
    Name = "${var.app_name}-subnet-public-a"
  }
}

resource "aws_subnet" "main_subnet_public_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  availability_zone       = "${var.aws_region}b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true # Ensure instances get public IPs

  tags = {
    Name = "${var.app_name}-subnet-public-b"
  }
}

# ##############################
# Internet Gateway
# ##############################
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# ##############################
# Route Table
# ##############################
resource "aws_route_table" "main_rt_public" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.app_name}-route-table"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.main_subnet_public_a.id
  route_table_id = aws_route_table.main_rt_public.id
}

resource "aws_route_table_association" "rta_public_b" {
  subnet_id      = aws_subnet.main_subnet_public_b.id
  route_table_id = aws_route_table.main_rt_public.id
}
