resource "aws_iam_role" "gymcoach_rds_secret_access_role" {
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

