resource "aws_ecr_repository" "container_repository" {
  name = var.container_repository_name
}

resource "aws_ecr_lifecycle_policy" "container_repository_policy" {
  repository = aws_ecr_repository.container_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 3 images",
        selection    = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 3,
        },
        action       = {
          type = "expire",
        },
      },
    ],
  })
}