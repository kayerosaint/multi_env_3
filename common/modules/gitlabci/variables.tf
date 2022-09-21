variable "env" {}

variable "region" {}

variable "subnet_ids_gitlab_runner" {}

variable "subnet_id_runners" {}

variable "gitlab_runner_registration_token" {}

variable "ci_prefix" {}

variable "locked_to_project" {
  type = bool
}

variable "run_untagged" {
  type = bool
}

variable "maximum_timeout" {
  type = number
}

variable "gitlab_runner_version" {}

variable "docker_machine_instance_type" {}

variable "instance_type" {}

variable "cloudwatch_logging_retention_in_days" {}
