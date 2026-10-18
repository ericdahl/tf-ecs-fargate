variable "name" {
  default = "tf-ecs-fargate"
}

variable "route53_zone_id" {
  default = ""
}

variable "enable_httpbin" {
  default = false
}
