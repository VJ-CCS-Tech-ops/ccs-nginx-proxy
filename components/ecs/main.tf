data "aws_efs_file_system" "nginx_efs_file_system" {
  tags = {
    Name = var.nginx_efs_name
  }
}

# TODO: See if there's a more suitable way of retrieving the AWS EFS Access Point
data "aws_efs_access_point" "nginx_efs_access_point" {
  access_point_id = "fsap-05203f565fce9700e"
}

data "aws_iam_role" "nginx_role" {
  name = var.nginx_role
}

data "aws_iam_role" "nginx_execution_role" {
  name = var.nginx_execution_role
}

data "aws_lb_target_group" "nginx_elb_target_group" {
  name = var.nginx_target_group_name
}

data "aws_security_group" "nginx_security_group" {
  name = var.nginx_security_group_name
}

data "aws_subnet" "nginx_private_subnet_a" {
  tags = {
    Name = var.nginx_private_subnet_a_name
  }
}

data "aws_subnet" "nginx_private_subnet_b" {
  tags = {
    Name = var.nginx_private_subnet_b_name
  }
}

resource "aws_ecs_cluster" "nginx_ecs_cluster" {
  name = var.nginx_ecs_cluster_name
}

resource "aws_ecs_task_definition" "nginx_ecs_task_definition" {
  container_definitions = file("task_definitions/nginx_container_definition.json")
  cpu                   = "512"
  #execution_role_arn    = data.aws_iam_role.nginx_execution_role.arn
  execution_role_arn       = "arn:aws:iam::473251818902:role/nginxExecutionRole"
  family                   = "nginx-task"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2", "FARGATE"]
  #task_role_arn            = "${var.nginx_role}".arn
  #task_role_arn = data.aws_iam_role.nginx_execution_role.arn

  volume {
    name = "nginx-home"

    efs_volume_configuration {
      # file_system_id     = data.aws_efs_file_system.nginx_efs_file_system.id
      file_system_id     = "fsap-0c9375636173db3b8"
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = data.aws_efs_access_point.nginx_efs_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "nginx_ecs_service" {
  name                               = var.nginx_ecs_service_name
  cluster                            = aws_ecs_cluster.nginx_ecs_cluster.id
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  desired_count                      = 1
  health_check_grace_period_seconds  = 300
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  task_definition                    = aws_ecs_task_definition.nginx_ecs_task_definition.arn

  network_configuration {
    assign_public_ip = true
    subnets          = [data.aws_subnet.nginx_private_subnet_a.id, data.aws_subnet.nginx_private_subnet_b.id]
    security_groups  = [data.aws_security_group.nginx_security_group.id]
  }

  load_balancer {
    container_name   = var.nginx_container_name
    container_port   = 8080
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:473251818902:loadbalancer/app/nginxLoadBalancer/09bdde31ec36e3fb"
    #target_group_arn = data.aws_lb_target_group.nginx_elb_target_group.arn
  }
}
