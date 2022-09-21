locals {
  url  = aws_ecr_repository.repo.repository_url
  name = aws_ecr_repository.repo.name
}


resource "aws_ecr_repository" "repo" {
  name = var.name
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repo.name

  policy = jsonencode({
    rules = concat([
      for value in var.important_environments : {
        rulePriority = value.priority
        description  = "${value.name}: keep last ${value.amount_to_keep} images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = [value.name]
          countType     = "imageCountMoreThan"
          countNumber   = value.amount_to_keep
        }
      }
      ], [
      {
        rulePriority = 1000
        description  = "Keep last images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.amount_to_keep
        }
      }
    ])
  })
}
