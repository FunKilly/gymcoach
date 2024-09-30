resource "aws_ecr_repository" "gymcoach_ecr_repository" {
  name                 = "ecr-${var.application_name}-${var.environment_name}-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    application = var.application_name
    environment = var.environment_name
  }

}

resource "aws_iam_group" "gymcoach_image_pushers_group" {
  name = "ecr-${var.application_name}-${var.environment_name}-ecr-image-pushers"
}

resource "aws_iam_group_policy" "gymcoach_image_pushers_group_policy" {
  name  = "ecr-${var.application_name}-${var.environment_name}-images-push-policy"
  group = aws_iam_group.gymcoach_image_pushers_group.name
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload", ]
          Resource = aws_ecr_repository.gymcoach_ecr_repository.arn
      }]
    }
  )
}

resource "aws_iam_group_membership" "gymcoach_image_pushers_group_membership" {
  name  = "ecr-${var.application_name}-ecr-image-push-membership"
  users = var.ecr_image_pushers
  group = aws_iam_group.gymcoach_image_pushers_group.name
}

