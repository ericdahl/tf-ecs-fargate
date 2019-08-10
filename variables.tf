variable "admin_cidr" {
  default = ""
}


/*
 * Service/Feature toggles
 */
variable "enable_fargate_httpbin" {
  default = "false"
}
