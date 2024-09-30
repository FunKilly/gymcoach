resource "aws_lb" "gymcoach_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gymcoach_alb_sg.id]
  subnets            = [aws_subnet.gymcoach_public_subnet_1.id, aws_subnet.gymcoach_private_subnet_2.id]
}


resource "aws_security_group" "gymcoach_alb_sg" {
  vpc_id = aws_vpc.gymcoach_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb_target_group" "gymcoach_alb_target_group" {
  name        = "gymcoach-target-group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.gymcoach_vpc.id
  target_type = "ip"

  health_check {
    path              = "/health"
    protocol          = "HTTP"
    port              = "8000"
    interval          = 30
    timeout           = 5
    healthy_threshold = 2
  }
}

# Listener for ALB to route traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.gymcoach_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gymcoach_alb_target_group.arn
  }
}