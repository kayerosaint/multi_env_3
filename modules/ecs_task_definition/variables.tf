variable "project" {
  description = "project name"
  type        = string
}

variable "env" {
  description = "development"
  type        = string
}

variable "network_mode" {
  default = "awsvpc"
  type    = string
}

variable "requires_compatibilities" {}

variable "cpu" {}

variable "memory" {}

variable "execution_role_arn" {}

variable "task_role_arn" {}

variable "container_definitions" {}
