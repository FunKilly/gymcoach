resource "aws_iam_role_policy_attachment" "gymcoach_ecs_secrets_policy_attachment" {
  role       = aws_iam_role.gymcoach_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.gymcooach_ecs_task_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "gymcoach_ecs_cloudwatch_logs" {
  role       = aws_iam_role.gymcoach_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_security_group" "gymcoach_rds_sg" {
  name        = "gymcoach-rds-sg"
  description = "Allow ECS to connect to RDS"
  vpc_id      = aws_vpc.gymcoach_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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


resource "aws_iam_role_policy_attachment" "gymcoach_ecs_task_secrets_attachment" {
  role       = aws_iam_role.gymcoach_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.gymcooach_ecs_task_secrets_policy.arn
}

resource "aws_iam_policy" "gymcooach_ecs_task_secrets_policy" {
  name = "gymcoach-ecs-task-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_db_instance.gymcoach_database.master_user_secret[0].secret_arn # Reference your secret ARN
      }
    ]
  })
}