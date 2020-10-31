variable "name" {
  default = "tf-ecs-fargate"
}

variable "admin_cidr" {
}

variable "public_key" {
}

variable "route53_zone_id" {
  default = ""
}

variable "enable_httpbin" {
  default = false
}
