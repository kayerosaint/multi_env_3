variable "env" {
  default = "development"
  type    = string
}

variable "container_port" {}

variable "project" {
  description = "project name"
  type        = string
}

variable "vpc_id" {
  default = "dev"
}
