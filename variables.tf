variable "admin_cidr" {
  default = ""
}

variable "public_key" {
  default = ""
}


/*
 * Service/Feature toggles
 */
variable "enable_fargate_httpbin" {
  default = "false"
}

variable "enable_splunk" {
  default = "false"
}