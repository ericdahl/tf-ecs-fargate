provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "github.com/ericdahl/tf-vpc"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "jumphost_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jumphost" {
  name               = "${var.name}-jumphost"
  assume_role_policy = data.aws_iam_policy_document.jumphost_assume_role.json
}

resource "aws_iam_role_policy_attachment" "jumphost_ssm" {
  role       = aws_iam_role.jumphost.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jumphost" {
  name = "${var.name}-jumphost"
  role = aws_iam_role.jumphost.name
}


resource "aws_instance" "jumphost" {

  ami = data.aws_ssm_parameter.al2023.value

  instance_type          = "t3.micro"
  subnet_id              = module.vpc.subnet_public1
  vpc_security_group_ids = [module.vpc.sg_allow_egress]
  iam_instance_profile   = aws_iam_instance_profile.jumphost.name


  tags = {
    Name      = var.name
    ManagedBy = "tf-ecs-fargate"
  }
}