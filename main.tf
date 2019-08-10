provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source        = "github.com/ericdahl/tf-vpc"
  admin_ip_cidr = "${var.admin_cidr}"
}

module "ecs" {
  source = "ecs_cluster"

  cluster_name = "tf-ecs-fargate"
}
