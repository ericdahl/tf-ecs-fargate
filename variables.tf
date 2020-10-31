variable "name" {
  default = "tf-ecs-fargate"
}

variable "admin_cidr" {
}

variable "public_key" {
}


variable "enable_fargate_httpbin" {
  default = false
}
