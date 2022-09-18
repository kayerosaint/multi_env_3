resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.project}-${var.env}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.env
    Application = var.project
  }
}
