# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-ecs-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-ecs-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-ecs-public-subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-ecs-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

