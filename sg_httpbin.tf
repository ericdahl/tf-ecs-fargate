resource "aws_security_group" "httpbin_lb" {
  name   = "${var.name}-httpbin-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "httpbin_lb_http" {
  security_group_id = aws_security_group.httpbin_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "httpbin_lb_to_task" {
  security_group_id            = aws_security_group.httpbin_lb.id
  referenced_security_group_id = aws_security_group.httpbin_task.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_security_group" "httpbin_task" {
  name   = "${var.name}-httpbin-task"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "httpbin_task_from_lb" {
  security_group_id            = aws_security_group.httpbin_task.id
  referenced_security_group_id = aws_security_group.httpbin_lb.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

# image pulls (via NAT) and, later, ECS Exec's ssmmessages channel
resource "aws_vpc_security_group_egress_rule" "httpbin_task_https" {
  security_group_id = aws_security_group.httpbin_task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "httpbin_task_from_jumphost" {
  security_group_id            = aws_security_group.httpbin_task.id
  referenced_security_group_id = aws_security_group.jumphost.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}
