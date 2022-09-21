#==========================Role ECS-EXEC============================#

resource "aws_iam_user" "ecs_exec" {
  name = "ecs-exec"
}

resource "aws_iam_access_key" "ecs_exec" {
  user = aws_iam_user.ecs_exec.name
}

data "aws_iam_policy_document" "assume_ecs_exec_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [aws_iam_user.ecs_exec.arn]
      type        = "AWS"
    }
  }
}

#========================Access_ECS-EXEC=============================#

resource "aws_iam_role" "ecs_exec" {
  name               = "ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_exec_role.json

  managed_policy_arns = [aws_iam_policy.ecs_exec.arn]
}

resource "aws_iam_policy" "ecs_exec" {
  name = "ecs-exec-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Sid    = "AccessECSEXEC"
        Action = [
          "ecs:ListClusters",
          "ecs:ListTasks",
        ]
        Resource = "*"
      },
    ]
  })
}

#============================Domain==================================#

resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_acm_certificate" "wildcard" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  zone_id         = aws_route53_zone.zone.id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

#===========================For GitLabCI=================================#

module "iam" {
  source = "./modules/iam"
  roles  = var.roles
  users  = var.users
}

module "dns" {
  source = "./modules/dns"
  domain = var.domain
}

module "ecr" {
  source = "./modules/ecr"

  for_each               = var.containers
  name                   = "${var.project}-${var.app}-${each.value.name}"
  important_environments = var.important_environments
  amount_to_keep         = 30
}
/*
resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az" {
  availability_zone = "${var.region}a"
}
*/
data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "dev"
  }
}

module "gitlabci" {
  source = "./modules/gitlabci"

  #vpc_id                              = aws_default_vpc.default.id
  #subnet_ids_gitlab_runner            = [aws_default_subnet.default_az.id]
  #subnet_id_runners                   = aws_default_subnet.default_az.id
  vpc_id                               = data.aws_vpc.dev_vpc.id
  subnet_ids_gitlab_runner             = [var.public_subnets]
  subnet_id_runners                    = var.public_subnets
  availability_zones                   = var.availability_zones
  region                               = var.region
  ci_prefix                            = var.project
  environment                          = "ci"
  gitlab_runner_version                = "13.12.0"
  docker_machine_instance_type         = "t3.micro"
  instance_type                        = "t3.micro"
  gitlab_runner_registration_token     = var.runner_token
  locked_to_project                    = true
  run_untagged                         = false
  maximum_timeout                      = "7200"
  cloudwatch_logging_retention_in_days = 90
}

#==========================Moved Blocks===============================#

moved {
  from = aws_acm_certificate.wildcard
  to   = module.dns.aws_acm_certificate.wildcard
}

moved {
  from = aws_route53_zone.zone
  to   = module.dns.aws_route53_zone.zone
}

moved {
  from = aws_route53_record.validation
  to   = module.dns.aws_route53_record.validation
}

moved {
  from = aws_acm_certificate_validation.validation
  to   = module.dns.aws_acm_certificate_validation.validation
}
