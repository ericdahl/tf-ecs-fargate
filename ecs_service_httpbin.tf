data "aws_region" "current" {}

resource "aws_ecs_task_definition" "httpbin" {
  container_definitions = jsonencode([
    {
      name  = "httpbin"
      image = "ericdahl/httpbin:e249975"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.httpbin.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "httpbin"
        }
      }
    }
  ])
  family = "httpbin"

  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512
}

resource "aws_ecs_service" "httpbin" {
  name            = "httpbin"
  cluster         = aws_ecs_cluster.default.name
  task_definition = aws_ecs_task_definition.httpbin.arn
  desired_count   = 10

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    security_groups = [
      aws_security_group.httpbin_task.id,
    ]

    subnets = [
      module.vpc.subnet_private1,
      module.vpc.subnet_private2,
      module.vpc.subnet_private3,
    ]
  }

  depends_on = [
    aws_cloudwatch_log_group.httpbin,
    aws_lb_listener.httpbin,
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.httpbin.arn
    container_name   = "httpbin"
    container_port   = 8080
  }
}

resource "aws_cloudwatch_log_group" "httpbin" {
  name = "/ecs/httpbin"

  retention_in_days = 7
}

resource "aws_lb" "httpbin" {
  name = "httpbin"

  subnets = [
    module.vpc.subnet_public1,
    module.vpc.subnet_public2,
    module.vpc.subnet_public3,
  ]

  security_groups = [
    aws_security_group.httpbin_lb.id,
  ]
}

resource "aws_lb_listener" "httpbin" {
  default_action {
    target_group_arn = aws_lb_target_group.httpbin.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.httpbin.arn
  port              = 80
}

resource "aws_lb_target_group" "httpbin" {
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

resource "aws_route53_record" "httpbin" {
  count = var.route53_zone_id != "" ? 1 : 0

  name    = "httpbin"
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.httpbin.dns_name
    zone_id                = aws_lb.httpbin.zone_id
  }
}