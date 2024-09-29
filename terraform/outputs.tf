output "backend_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
output "postgres_connection_string" {
  value = "postgresql://${var.db_username}:${aws_db_instance.my_database.master_user_secret.0.secret_arn}@${aws_db_instance.my_database.address}:${tostring(aws_db_instance.my_database.port)}/${aws_db_instance.my_database.db_name}"
}

output "load_balancer_url" {
  value = aws_lb.my_alb.dns_name
}