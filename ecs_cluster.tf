resource "aws_ecs_cluster" "default" {
  name = var.name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        s3_bucket_name               = aws_s3_bucket.session_logs.bucket
        s3_key_prefix                = "ecs-exec"
        s3_bucket_encryption_enabled = true
      }
    }
  }

  tags = {
    ClusterName = var.name
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.default.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }
}
