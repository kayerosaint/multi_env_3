variable "project" {
  description = "project name"
}

variable "env" {
  description = "development"

}

variable "health_check_path" {
  description = "Health check path"
}

variable "vpc_id" {}

variable "subnets" {
  description = "Public subnets"
}

variable "security_groups" {
  description = "SG for ALB"
}

variable "certificate_arn" {}
