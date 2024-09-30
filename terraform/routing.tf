resource "aws_internet_gateway" "gymcoach_igw" {
  vpc_id = aws_vpc.gymcoach_vpc.id

  tags = {
    Name = "gymcoach-ecs-igw"
  }
}

resource "aws_subnet" "gymcoach_public_subnet_1" {
  vpc_id                  = aws_vpc.gymcoach_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "gymcoach-ecs-public-subnet"
  }
}

resource "aws_subnet" "gymcoach_public_subnet_2" {
  vpc_id                  = aws_vpc.gymcoach_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "gymcoach-ecs-public-subnet"
  }
}

resource "aws_route_table" "gymcoach_public_route_table" {
  vpc_id = aws_vpc.gymcoach_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gymcoach_igw.id
  }

  tags = {
    Name = "gymcoach-public-route-table"
  }
}

resource "aws_route_table_association" "gymcoach_public_subnet_association_2" {
  subnet_id      = aws_subnet.gymcoach_public_subnet_1.id
  route_table_id = aws_route_table.gymcoach_public_route_table.id
}

resource "aws_route_table_association" "gymcoach_public_subnet_association_1" {
  subnet_id      = aws_subnet.gymcoach_public_subnet_2.id
  route_table_id = aws_route_table.gymcoach_public_route_table.id
}


resource "aws_subnet" "gymcoach_private_subnet_1" {
  vpc_id                  = aws_vpc.gymcoach_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "gymcoach_private_subnet_2" {
  vpc_id                  = aws_vpc.gymcoach_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false
}


resource "aws_security_group" "gymcoach_ecs_sg" {
  name        = "gymcoach-ecs-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.gymcoach_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
