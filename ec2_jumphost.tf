data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
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
