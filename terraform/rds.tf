resource "aws_db_instance" "gymcoach_database" {
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  db_name           = var.db_name
  username          = var.db_username

  db_subnet_group_name   = aws_db_subnet_group.gymcoach_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.gymcoach_rds_sg.id]

  manage_master_user_password = true # Enable management of the password
  skip_final_snapshot         = true

}


resource "aws_db_subnet_group" "gymcoach_db_subnet_group" {
  name       = "gymcoach-db-subnet-group"
  subnet_ids = [aws_subnet.gymcoach_private_subnet_1.id, aws_subnet.gymcoach_private_subnet_2.id]

  tags = {
    Name = "gymcoach-db-subnet-group"
  }
}



