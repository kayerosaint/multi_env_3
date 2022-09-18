resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster-${var.env}"
  tags = {
    Name        = "${var.project}-cluster-${var.env}"
    Environment = var.env
  }
}

output "id" {
  value = aws_ecs_cluster.main.id
}

output "name" {
  value = aws_ecs_cluster.main.name
}
