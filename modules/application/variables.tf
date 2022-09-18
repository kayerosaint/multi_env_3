
variable "project" {
  description = "project name"
}

variable "env" {
  description = "development"
  type        = string
}

variable "task_cpu" {
  description = "cpu usage"
  type        = string
}

variable "task_memory" {
  description = "memory usage"
  type        = string
}

variable "image" {
  description = "ecs image"
  type        = string
}

variable "container_port" {
  type = number
}


#================ALB=================#
variable "alb_sg" {
  description = "SG for ALB"
}

variable "vpc_id" {}

variable "public_subnets" {}

#=============ECS Services===========#

variable "private_subnets" {}

variable "ecs_sg" {
  description = "SG for ECS"
}

#============LOGS/Dasboard===========#

variable "region" {
  description = "aws region/for dashboard"
}
#==============secrets================#

variable "secrets" {
  description = "app secrets"
  type        = map(string)
}

#=======variables for app=============#

variable "variables" {
  description = "app variables"
}
#==============domain=================#

variable "domain" {
  description = "domain name for app"
}
