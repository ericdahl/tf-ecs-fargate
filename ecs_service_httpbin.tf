data "template_file" "httpbin" {
  template = file("templates/tasks/httpbin.json")
}

resource "aws_ecs_task_definition" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  container_definitions = data.template_file.httpbin.rendered
  family                = "httpbin"

  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = module.ecs.aws_iam_role_ecs_task_execution_arn

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512
}

resource "aws_ecs_service" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  name            = "httpbin"
  cluster         = module.ecs.cluster_name
  task_definition = aws_ecs_task_definition.httpbin[count.index].arn
  desired_count   = 10

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    security_groups = [
      module.vpc.sg_allow_8080,
      module.vpc.sg_allow_egress,
      module.vpc.sg_allow_vpc,
    ]

    subnets = [
      module.vpc.subnet_private1,
    ]
  }

  depends_on = [
    aws_cloudwatch_log_group.httpbin,
    aws_lb.httpbin
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.httpbin[count.index].arn
    container_name   = "httpbin"
    container_port   = 8080
  }
}

resource "aws_cloudwatch_log_group" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  name = "/ecs/httpbin"

  retention_in_days = 7
}

resource "aws_lb" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  name = "httpbin"

  subnets = [
    module.vpc.subnet_public1,
    module.vpc.subnet_public2,
    module.vpc.subnet_public3,
  ]

  security_groups = [
    module.vpc.sg_allow_egress,
    module.vpc.sg_allow_80,
  ]
}

resource "aws_lb_listener" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  default_action {
    target_group_arn = aws_lb_target_group.httpbin[count.index].arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.httpbin[count.index].arn
  port              = 80
}

resource "aws_lb_target_group" "httpbin" {
  count = var.enable_httpbin ? 1 : 0

  name                 = "httpbin"
  vpc_id               = module.vpc.vpc_id
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 0
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 5
    timeout             = 2
  }
}
