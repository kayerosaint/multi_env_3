#Create ECS, runs and maintains the requested number of tasks and associated load balancers
resource "aws_ecs_service" "main" {
  name                               = "${var.project}-service-${var.env}"
  cluster                            = var.cluster_id
  task_definition                    = var.task_definition_arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.min_percent
  deployment_maximum_percent         = var.max_percent
  launch_type                        = var.launch_type
  scheduling_strategy                = var.scheduling_strategy
  enable_execute_command             = var.enable_execute_command

  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.private_subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
