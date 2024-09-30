resource "aws_ecs_cluster" "gymcoach_ecs_cluster" {
  name = "gymcoach-ecs-cluster"
}

resource "aws_ecs_task_definition" "gymcoach-app" {
  family                   = "gymcoach-app"
  requires_compatibilities = ["EC2"]  # EC2 for running on EC2 instances
  network_mode             = "awsvpc" # For VPC networking
  execution_role_arn       = aws_iam_role.gymcoach_ecs_task_execution_role.arn
  cpu                      = "256" # 256 CPU units (¼ CPU)
  memory                   = "512" # 512 MB of memory

  container_definitions = jsonencode([
    {
      name      = "gymcoach-app-container"
      image     = "${aws_ecr_repository.gymcoach_ecr_repository.repository_url}:latest" # Image from ECR
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/gymcoach-app-container"
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      # Add this section to reference secrets
      secrets = [
        {
          name      = "POSTGRES_PASSWORD" # The environment variable in your container
          valueFrom = "${aws_db_instance.gymcoach_database.master_user_secret.0.secret_arn}:password::"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_SERVER"
          value = aws_db_instance.gymcoach_database.address
        },
        {
          name  = "POSTGRES_USER"
          value = var.db_username
        },
        {
          name  = "POSTGRES_DB"
          value = aws_db_instance.gymcoach_database.db_name
        },
        {
          name  = "POSTGRES_PORT"
          value = tostring(aws_db_instance.gymcoach_database.port)
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "gymcoach_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.gymcoach_ecs_cluster.id
  task_definition = aws_ecs_task_definition.gymcoach-app.arn
  desired_count   = 1 # Number of tasks to run
  launch_type     = "EC2"

  # Load balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.gymcoach_alb_target_group.arn
    container_name   = "gymcoach-app-container"
    container_port   = 8000
  }

  network_configuration {
    subnets         = [aws_subnet.gymcoach_private_subnet_1.id, aws_subnet.gymcoach_private_subnet_2.id] # Use private subnets for tasks
    security_groups = [aws_security_group.gymcoach_ecs_sg.id]
  }

  depends_on = [aws_lb.gymcoach_alb]

}


resource "aws_instance" "gymcoach_ecs_instance" {
  ami                  = "ami-099d1a494e1ddfd58"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.gymcoach_ecs_instance_profile.name

  vpc_security_group_ids = [aws_security_group.gymcoach_ecs_sg.id]
  subnet_id              = aws_subnet.gymcoach_public_subnet_1.id

  # Ensure this EC2 instance registers with the ECS cluster
  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.gymcoach_ecs_cluster.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_iam_role" "gymcoach_ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "gymcoach_ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.gymcoach_ecs_instance_role.name
}


resource "aws_iam_policy_attachment" "gymcoach_ecs_instance_policy" {
  name       = "Ec2InstanceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  roles      = [aws_iam_role.gymcoach_ecs_instance_role.name]
}

resource "aws_iam_policy_attachment" "ecr_read_policy" {
  name       = "EC2ReadPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.gymcoach_ecs_instance_role.name]
}

resource "aws_cloudwatch_log_group" "gymcoach_ecs_log_group" {
  name              = "/ecs/gymcoach-app-container"
  retention_in_days = 7
}

resource "aws_iam_policy_attachment" "gymcoach_ecs_task_execution_policy" {
  name       = "AmazonECSTaskExecutionRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.gymcoach_ecs_task_execution_role.name]
}
