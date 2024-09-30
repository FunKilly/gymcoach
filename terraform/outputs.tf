output "gymcoach_backend_repository_url" {
  value = aws_ecr_repository.gymcoach_ecr_repository.repository_url
}

output "load_balancer_url" {
  value = aws_lb.gymcoach_alb.dns_name
}