variable "env" {
  default = "development"
}

variable "public_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "vpc_cidr_blocks" {}


variable "availability_zones" {
  description = "availability zones list"
}
