

output "cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "aws_iam_role_ecs_task_execution_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}