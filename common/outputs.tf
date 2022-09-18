output "secret_key" {
  value     = aws_iam_access_key.ecs_exec.secret
  sensitive = true
}

output "access_token" {
  value = aws_iam_access_key.ecs_exec.id
}

output "role_arn" {
  value = aws_iam_role.ecs_exec.arn
}

output "region" {
  value = var.region
}

output "format" {
  value = "json"
}
