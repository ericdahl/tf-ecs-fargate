data "aws_iam_policy_document" "ecs_task_httpbin_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_httpbin" {
  name = "${var.name}-ecs-task-httpbin"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_httpbin_assume_role.json
}

# ECS Exec: lets the SSM agent injected into the container open its session channels
data "aws_iam_policy_document" "ecs_task_httpbin" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_httpbin" {
  name   = "${var.name}-ecs-task-httpbin"
  policy = data.aws_iam_policy_document.ecs_task_httpbin.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_httpbin" {
  role       = aws_iam_role.ecs_task_httpbin.name
  policy_arn = aws_iam_policy.ecs_task_httpbin.arn
}
