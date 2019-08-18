data "template_file" "splunk" {
  template = "${file("templates/tasks/splunk.json")}"
}

resource "aws_ecs_task_definition" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  container_definitions = "${data.template_file.splunk.rendered}"
  family                = "splunk"

  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = "${module.ecs.aws_iam_role_ecs_task_execution_arn}"

  network_mode = "awsvpc"
  cpu          = 2048
  memory       = 4096
}

resource "aws_ecs_service" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  name            = "splunk"
  cluster         = "${module.ecs.cluster_name}"
  task_definition = "${aws_ecs_task_definition.splunk.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
      "${module.vpc.sg_allow_8080}",
      "${module.vpc.sg_allow_egress}",
      "${module.vpc.sg_allow_vpc}",
    ]

    subnets = [
      "${module.vpc.subnet_private1}",
    ]
  }

  depends_on = ["aws_alb.splunk"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.splunk.arn}"
    container_name   = "splunk"
    container_port   = 8000
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.splunk_hec.arn}"
    container_name   = "splunk"
    container_port   = 8088
  }

  health_check_grace_period_seconds = 300
}

resource "aws_cloudwatch_log_group" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  name = "/ecs/splunk"

  retention_in_days = 7
}

resource "aws_security_group" "allow_8088" {
  vpc_id = "${module.vpc.vpc_id}"
  name = "splunk-hec"
}

resource "aws_security_group_rule" "allow_8080" {

  security_group_id = "${aws_security_group.allow_8088.id}"

  type = "ingress"
  protocol = "tcp"
  from_port = 8088
  to_port = 8088

  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_alb" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  name = "splunk"

  subnets = [
    "${module.vpc.subnet_public1}",
    "${module.vpc.subnet_public2}",
    "${module.vpc.subnet_public3}",
  ]

  security_groups = [
    "${module.vpc.sg_allow_egress}",
    "${module.vpc.sg_allow_80}",
    "${aws_security_group.allow_8088.id}",
  ]
}

resource "aws_alb_listener" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  default_action {
    target_group_arn = "${aws_alb_target_group.splunk.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_alb.splunk.arn}"
  port              = 80
}

resource "aws_alb_target_group" "splunk" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  name                 = "splunk"
  vpc_id               = "${module.vpc.vpc_id}"
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 5
    timeout             = 2
    matcher             = "200-299,303" # 303 for redirect to /en-US/ # TODO: use dedicated hc endpoint?
  }
}



resource "aws_alb_listener" "splunk_hec" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  default_action {
    target_group_arn = "${aws_alb_target_group.splunk_hec.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_alb.splunk.arn}"
  port              = 8088
}

resource "aws_alb_target_group" "splunk_hec" {
  count = "${var.enable_splunk == "true" ? 1 : 0}"

  name                 = "splunk-hec"
  vpc_id               = "${module.vpc.vpc_id}"
  port                 = 8088
  protocol             = "HTTP"
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    path                = "/services/collector/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 5
    timeout             = 2
    matcher             = "200-299,303" # 303 for redirect to /en-US/ # TODO: use dedicated hc endpoint?
  }
}
