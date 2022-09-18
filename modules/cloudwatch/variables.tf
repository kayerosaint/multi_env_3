variable "retention_in_days" {}

variable "env" {
  description = "development"
  type        = string
}

variable "project" {
  description = "project name"
  default     = "PACMAN-XXX"
  type        = string
}
