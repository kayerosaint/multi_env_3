output "container_definitions" {
  value = jsonencode(module.task_definition)
}
