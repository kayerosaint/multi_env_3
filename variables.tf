variable "region" {
  description = "aws region"
  type        = string
}

variable "image" {
  description = "container image you will run on the instance"
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

variable "instance_ami" {
  description = "AWS AMI"
  type        = string
}

variable "instance_user" {
  description = "instance user"
  type        = string
}

variable "env" {
  default     = "staging"
  description = "staging"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "vpc_cidr_blocks" {
  description = "List of private subnets"
  type        = string
}

variable "container_port" {
  description = "container port listen"

}

variable "project" {
  description = "project name"
}

variable "vpc_id" {
  description = "my created vpc"
  default     = "dev"
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "secrets" {
  description = "Secrets for app"
  type        = map(string)
}

variable "domain" {
  description = "domain name for app"
}
