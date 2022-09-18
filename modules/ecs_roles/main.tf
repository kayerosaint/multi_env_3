data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.env}_ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.env}_ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#===============ecs-task-role-policy-attachment-for-secrets===================#

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_iam_policy" "secrets" {
  name        = "${var.env}-task-policy-secrets"
  description = "Policy that allows access to the secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = var.secrets_arn
      },
    ]
  })
}

#===============ecs-task-role-policy-attachment-for-exec===================#

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-exec" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.exec.arn
}

resource "aws_iam_policy" "exec" {
  name        = "${var.env}-task-policy-exec"
  description = "Policy that allows ecs exec to task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessSecrets"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
    ]
  })
}
