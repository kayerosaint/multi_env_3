variable "project" {
  description = "project name"
  type        = string
}

variable "env" {
  description = "development"
  type        = string
}

variable "cluster_id" {}

variable "task_definition_arn" {}

variable "desired_count" {}

variable "min_percent" {}

variable "max_percent" {}

variable "launch_type" {}

variable "scheduling_strategy" {}

variable "aws_alb_target_group_arn" {}

variable "container_name" {}

variable "container_port" {}

variable "private_subnets" {}

variable "security_groups" {
  description = "SG for ECS"
}

variable "enable_execute_command" {
  description = "for ecs-exec"
}
