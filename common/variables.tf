variable "region" {}

variable "domain" {}

variable "roles" {
  type = map(
    list(
      string
    )
  )
}

variable "users" {
  type = map(
    object({
      name = string,
      role = string,
      key  = bool,
    })
  )
}

variable "containers" {
  type = map(object({
    name = string
  }))
}

variable "project" {}

variable "app" {}

variable "important_environments" {}

variable "runner_token" {}


variable "public_subnets" {
  description = "List of public subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}
