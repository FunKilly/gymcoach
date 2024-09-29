resource "aws_db_instance" "my_database" {
  allocated_storage       = 20
  engine                = "postgres"
  engine_version        = "16"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  username              = var.db_username

  db_subnet_group_name  = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  manage_master_user_password = true  # Enable management of the password
  skip_final_snapshot = true

}


resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "my-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow ECS to connect to RDS"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    #security_groups = [aws_security_group.my_ecs_sg.id]  # Only allow ECS security group access
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

