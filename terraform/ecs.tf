resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
}


resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["EC2"]  # EC2 for running on EC2 instances
  network_mode              = "awsvpc"  # For VPC networking
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  cpu                       = "256"    # 256 CPU units (¼ CPU)
  memory                    = "512"    # 512 MB of memory

  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "${data.terraform_remote_state.first_configuration.outputs.backend_repository_url}:latest"  # Image from ECR
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
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1  # Number of tasks to run
  launch_type     = "EC2"

  network_configuration {
    subnets         = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.my_ecs_sg.id]
    assign_public_ip = true
  }
}


resource "aws_instance" "ecs_instance" {
  ami                         = "ami-12345678"  # Use ECS-optimized AMI
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  key_name                    = "my-key"
  vpc_security_group_ids      = [aws_security_group.my_ecs_sg.id]
  subnet_id                   = aws_subnet.public_subnet.id

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