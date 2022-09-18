locals {
  variables = {
    PORT = var.container_port
  }
}

module "networking" {
  source             = "./modules/networking"
  env                = "staging"
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  vpc_cidr_blocks    = var.vpc_cidr_blocks
}

module "security_groups" {
  source         = "./modules/security_groups"
  project        = "${var.project}-${var.env}"
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
}

module "ssh" {
  source = "./modules/ssh"
  env    = var.env
}

module "application" {
  source          = "./modules/application"
  domain          = var.domain
  project         = var.project
  env             = var.env
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory
  image           = var.image
  container_port  = var.container_port
  region          = var.region
  variables       = local.variables
  secrets         = var.secrets
  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  ecs_sg          = [module.security_groups.ecs_tasks]
  alb_sg          = [module.security_groups.alb]
}
