output "alb_arn" {
  value = aws_lb.main[*].arn
}

output "tg_arn" {
  value = aws_alb_target_group.main.arn
}

#============dashboard output================#

output "alb_arn_suffix" {
  value = aws_lb.main.arn_suffix
}

output "tg_arn_suffix" {
  value = aws_alb_target_group.main.arn_suffix
}

#=====

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}
