resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"                  # Health check path
    protocol            = "HTTP"                      # Health check protocol
    port                = "8000"                      # Port for the health check
    interval            = 30                          # Interval between health checks
    timeout             = 5                           # Timeout for health check response
    healthy_threshold   = 2                           # Healthy threshold count
    unhealthy_threshold = 2                           # Unhealthy threshold count
  }
}

# Listener for ALB to route traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}