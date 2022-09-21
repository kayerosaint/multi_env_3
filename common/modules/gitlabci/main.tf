resource "tls_private_key" "ci" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ci.private_key_pem
  filename        = "ssh_keys/${var.env}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "ci" {
  key_name   = "ci"
  public_key = tls_private_key.ci.public_key_openssh

  tags = {
    Name = "gitlab runner key pair"
  }
}

resource "aws_iam_policy" "ci_deploy_policy" {
  name        = "${var.env}-deploy"
  description = "Add access to ECS/ECR for CI/CD process"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcEndpoints",

          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart",

          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ExecuteCommand",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:UpdateService",

          "iam:PassRole",

          "sts:GetServiceBearerToken",
        ]
        Resource = "*"
      },
    ]
  })
}

data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "dev"
  }
}

module "gitlab-runner" {
  source  = "npalm/gitlab-runner/aws"
  version = "4.25.0"

  aws_region   = var.region
  environment  = var.env
  ssh_key_pair = aws_key_pair.ci.key_name

  vpc_id                   = data.aws_vpc.dev_vpc.id
  subnet_ids_gitlab_runner = var.subnet_ids_gitlab_runner
  subnet_id_runners        = var.subnet_id_runners

  runners_name       = "CI/CD runner"
  runners_gitlab_url = "https://gitlab.com/"

  gitlab_runner_registration_config = {
    registration_token = var.gitlab_runner_registration_token
    tag_list           = var.ci_prefix
    description        = "CI/CD runners"
    locked_to_project  = var.locked_to_project
    run_untagged       = var.run_untagged
    maximum_timeout    = var.maximum_timeout
  }

  runners_machine_autoscaling = [
    {
      timezone   = "Europe/Amsterdam",
      idle_count = 0,
      idle_time  = 60,
      periods    = ["* * 0-9,17-23 * * mon-fri *", "* * * * * sat,sun *"],
    }
  ]

  gitlab_runner_version                = var.gitlab_runner_version
  docker_machine_instance_type         = var.docker_machine_instance_type
  instance_type                        = var.instance_type
  runners_use_private_address          = false
  runner_iam_policy_arns               = [aws_iam_policy.ci_deploy_policy.arn]
  docker_machine_iam_policy_arns       = [aws_iam_policy.ci_deploy_policy.arn]
  cloudwatch_logging_retention_in_days = var.cloudwatch_logging_retention_in_days
}
