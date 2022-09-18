output "arn" {
  value = aws_secretsmanager_secret_version.application_secrets_values.*.arn
}

output "map" {
  value = local.secretMap
}
