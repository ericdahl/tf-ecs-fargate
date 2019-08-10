//resource "aws_iam_role" "ecs_service" {
//  name        = "${var.cluster_name}-service-role"
//  description = "Role applied to ECS Services, allowing them to register in ELB/ALB, etc"
//
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "",
//      "Effect": "Allow",
//      "Principal": {
//        "Service": "ecs.amazonaws.com"
//      },
//      "Action": "sts:AssumeRole"
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_policy_attachment" "ecs_service" {
//  name       = "${var.cluster_name}-ecs-service"
//  roles      = ["${aws_iam_role.ecs_service.name}"]
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
//}
