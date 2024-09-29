resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "gymcoach-app" {
  family                   = "gymcoach-app"
  requires_compatibilities = ["EC2"]  # EC2 for running on EC2 instances
  network_mode              = "awsvpc"  # For VPC networking
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  cpu                       = "256"    # 256 CPU units (¼ CPU)
  memory                    = "512"    # 512 MB of memory

  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "959733372523.dkr.ecr.eu-central-1.amazonaws.com/ecr-gymcoach-sandbox-backend:2024.09.42"  # Image from ECR
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/my-container"
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      # Add this section to reference secrets
      secrets = [
        {
          name      = "POSTGRES_PASSWORD"  # The environment variable in your container
          valueFrom = "${aws_db_instance.my_database.master_user_secret.0.secret_arn}:password::"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_SERVER"
          value = aws_db_instance.my_database.address
        },
        {
          name  = "POSTGRES_USER"
          value = var.db_username
        },
        {
          name  = "POSTGRES_DB"
          value = aws_db_instance.my_database.db_name
        },
        {
          name  = "POSTGRES_PORT"
          value = tostring(aws_db_instance.my_database.port)
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.gymcoach-app.arn
  desired_count   = 1  # Number of tasks to run
  launch_type     = "EC2"

  # Load balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "my-container"
    container_port   = 80
  }

  network_configuration {
    subnets         = [aws_subnet.private_1.id, aws_subnet.private_2.id]  # Use private subnets for tasks
    security_groups = [aws_security_group.my_ecs_sg.id]              # Security group for ECS tasks
  }

  depends_on = [aws_lb.my_alb]

}


resource "aws_instance" "ecs_instance" {
  ami                         = "ami-099d1a494e1ddfd58"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name

  vpc_security_group_ids      = [aws_security_group.my_ecs_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id

  # Ensure this EC2 instance registers with the ECS cluster
  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.my_ecs_cluster.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_iam_role" "ecs_instance_role" {
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

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}


resource "aws_iam_policy_attachment" "ecs_instance_policy" {
  name =  "Ec2InstanceRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  roles      = [aws_iam_role.ecs_instance_role.name]
}

resource "aws_iam_policy_attachment" "ecr_read_policy" {
  name =  "EC2ReadPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.ecs_instance_role.name]
}


resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = false
}


resource "aws_security_group" "my_ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

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