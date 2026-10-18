resource "aws_ecs_cluster" "default" {
  name = var.name

  tags = {
    ClusterName = var.name
  }
}
