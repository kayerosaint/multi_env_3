locals {
  app_name = "web"
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

module "cluster" {
  source  = "../ecs_cluster"
  project = var.project
  env     = var.env
}

#=========================ECS roles==============================#

module "roles" {
  source      = "../ecs_roles"
  env         = var.env
  secrets_arn = module.secrets.arn
}

#=======================ECS Task Definition======================#

module "task_definition" {
  source                   = "../ecs_task_definition"
  env                      = var.env
  project                  = var.project
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = module.roles.execution_role_arn
  task_role_arn            = module.roles.task_role_arn
  container_definitions = [
    {
      name      = local.app_name
      image     = var.image
      essential = true
      links     = []

      volumesFrom = []
      mountPoints = []
      links       = []
      environment = module.variables.map
      secrets     = module.secrets.map
      linuxParameters = {
        initProcessEnabled = true
      }
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = local.app_name
        }
      }
    }
  ]
}

#==================Application Load Balancer=======================#
data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "dev"
  }
}

module "alb" {
  source            = "../alb"
  project           = var.project
  env               = var.env
  security_groups   = var.alb_sg
  subnets           = var.public_subnets
  vpc_id            = data.aws_vpc.dev_vpc.id
  health_check_path = "/health_check"
  certificate_arn   = data.aws_acm_certificate.cert.arn
}

#===========================ECS SERVISE=============================#

module "service" {
  source                   = "../ecs_service"
  project                  = var.project
  env                      = var.env
  cluster_id               = module.cluster.id
  task_definition_arn      = module.task_definition.arn
  desired_count            = 2
  min_percent              = 50
  max_percent              = 300
  launch_type              = "FARGATE"
  scheduling_strategy      = "REPLICA"
  security_groups          = var.ecs_sg
  private_subnets          = var.private_subnets
  aws_alb_target_group_arn = module.alb.tg_arn
  container_port           = var.container_port
  container_name           = local.app_name
  enable_execute_command   = true
}

#===========================LOGS======================================#

module "logs" {
  source            = "../cloudwatch"
  env               = var.env
  project           = var.project
  retention_in_days = 90
}

#===========================Variables/Secrets==========================#

module "variables" {
  source = "../variables"
  map    = var.variables
}

module "secrets" {
  source  = "../secrets"
  project = var.project
  env     = var.env
  secrets = var.secrets
}

#===========================AUTOSCALING================================#

module "autoscaling" {
  source                = "../autoscaling"
  cluster_name          = module.cluster.name
  service_name          = module.service.name
  cpu_average_target    = 60
  memory_average_target = 60
  scale_in_cooldown     = 300
  scale_out_cooldown    = 150
  max_capacity          = 4
  min_capacity          = 1
}

#===========================Dashboard===================================#

module "dashboard" {
  source           = "../dashboard"
  project          = var.project
  env              = var.env
  region           = var.region
  target_group_arn = module.alb.tg_arn_suffix
  alb_arn          = module.alb.alb_arn_suffix
  cluster_name     = module.cluster.name
  service_name     = module.service.name
}

#================================DNS====================================#

module "dns" {
  source       = "../dns"
  domain       = var.domain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  env          = var.env
}
