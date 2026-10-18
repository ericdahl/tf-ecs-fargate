resource "aws_security_group" "jumphost" {
  name   = "${var.name}-jumphost"
  vpc_id = module.vpc.vpc_id
}

# SSM agent and dnf repos
resource "aws_vpc_security_group_egress_rule" "jumphost_https" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# the ALB is internet-facing, so it's reached via its public IPs (an SG reference wouldn't match)
resource "aws_vpc_security_group_egress_rule" "jumphost_http" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "jumphost_to_httpbin_task" {
  security_group_id            = aws_security_group.jumphost.id
  referenced_security_group_id = aws_security_group.httpbin_task.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}
