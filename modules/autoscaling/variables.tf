variable "min_capacity" {
  description = "task min capacity"
}

variable "max_capacity" {
  description = "task max capacity"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "service_name" {
  description = "service name"
}
#=========================
variable "memory_average_target" {
  description = "memory utilization target"
}

variable "cpu_average_target" {
  description = "cpu utilization target"
}
#=========================
variable "scale_in_cooldown" {
  description = "scaling IN"
}

variable "scale_out_cooldown" {
  description = "scaling OUT"
}
