resource "aws_secretsmanager_secret" "application_secrets" {
  count                   = length(var.secrets)
  name                    = "${var.project}-secrets-${var.env}-${element(keys(var.secrets), count.index)}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "application_secrets_values" {
  count         = length(var.secrets)
  secret_id     = element(aws_secretsmanager_secret.application_secrets.*.id, count.index)
  secret_string = element(values(var.secrets), count.index)
}

locals {
  secrets = zipmap(keys(var.secrets), aws_secretsmanager_secret_version.application_secrets_values.*.arn)

  secretMap = [
    for secretKey in keys(var.secrets) : {
      name      = secretKey
      valueFrom = lookup(local.secrets, secretKey)
    }
  ]
}
