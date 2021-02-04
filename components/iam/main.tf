data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_efs_file_system" "nginx_efs_file_system" {
  tags = {
    Name = var.nginx_efs_name
  }
}

data "aws_iam_policy_document" "default_ecs_iam_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "nginx_role_efs_policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Effect": "Allow",
      "Resource": "${data.aws_efs_file_system.nginx_efs_file_system.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "nginx_execution_role" {
  name               = var.nginx_execution_role
  assume_role_policy = data.aws_iam_policy_document.default_ecs_iam_policy.json
}

resource "aws_iam_policy_attachment" "nginx_execution_role_ecs_policy_attachment" {
  name       = "nginx-execution-role-ecs-policy-attachment"
  roles      = [aws_iam_role.nginx_execution_role.id]
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role" "nginx_role" {
  name               = var.nginx_role
  assume_role_policy = data.aws_iam_policy_document.default_ecs_iam_policy.json
}

resource "aws_iam_policy_attachment" "nginx_role_to_nginx_role_efs_policy" {
  name       = "nginx-role-to-nginx-role-efs-policy"
  roles      = [aws_iam_role.nginx_role.id]
  policy_arn = aws_iam_policy.nginx_role_efs_policy.arn
}
