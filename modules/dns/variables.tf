variable "domain" {
  default     = "infra.maks-k-one.site"
  description = "domain name for app"
}

variable "env" {
  default     = "staging"
  description = "staging"
}

variable "alb_dns_name" {
  description = "dns name"
}

variable "alb_zone_id" {
  description = "zone id"
}
