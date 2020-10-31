provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source        = "github.com/ericdahl/tf-vpc"
  admin_ip_cidr = var.admin_cidr
}

module "ecs" {
  source = "./ecs_cluster"

  cluster_name = var.name
}

data "aws_ssm_parameter" "ecs_optimized" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_key_pair" "ssh_public_key" {
  key_name   = var.name
  public_key = var.public_key
}


resource "aws_instance" "jumphost" {

  ami = data.aws_ssm_parameter.ecs_optimized.value

  instance_type          = "t2.small"
  subnet_id              = module.vpc.subnet_public1
  vpc_security_group_ids = [module.vpc.sg_allow_22, module.vpc.sg_allow_egress]
  key_name               = aws_key_pair.ssh_public_key.key_name


  tags = {
    Name      = var.name
    ManagedBy = "tf-ecs-fargate"
  }
}