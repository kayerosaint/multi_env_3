locals {
  env_domain = "${var.env}.${var.domain}"
}

data "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "environment" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.env_domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
