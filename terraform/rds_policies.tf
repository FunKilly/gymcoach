resource "aws_iam_role" "rds_secret_access_role" {
  name = "rds-secret-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com",
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_task_secrets_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_secrets_policy.arn
}

resource "aws_iam_policy" "ecs_task_secrets_policy" {
  name = "ecs_task_secrets_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_db_instance.my_database.master_user_secret[0].secret_arn  # Reference your secret ARN
      }
    ]
  })
}