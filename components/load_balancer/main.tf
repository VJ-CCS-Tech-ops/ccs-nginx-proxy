data "aws_acm_certificate" "nginx_acm_cert" {
  domain = var.acm_domain_name
}

data "aws_security_group" "nginx_load_balancer_security_group" {
  name = var.nginx_load_balancer_security_group_name
}

data "aws_subnet" "nginx_public_subnet_a" {
  tags = {
    Name = var.nginx_public_subnet_a_name
  }
}

data "aws_subnet" "nginx_public_subnet_b" {
  tags = {
    Name = var.nginx_public_subnet_b_name
  }
}

data "aws_vpc" "nginx_vpc" {
  tags = {
    Name = var.nginx_vpc_name
  }
}

resource "aws_lb" "nginx_load_balancer" {
  name            = var.nginx_load_balancer_name
  subnets         = [data.aws_subnet.nginx_public_subnet_a.id, data.aws_subnet.nginx_public_subnet_b.id]
  security_groups = [data.aws_security_group.nginx_load_balancer_security_group.id]
}

resource "aws_lb_target_group" "nginx_elb_target_group" {
  deregistration_delay = 10
  name                 = var.nginx_target_group_name
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.nginx_vpc.id

  health_check {
    path = "/login"
  }
}

resource "aws_lb_listener" "nginx_elb_listener" {
  load_balancer_arn = aws_lb.nginx_load_balancer.arn
  certificate_arn   = data.aws_acm_certificate.nginx_acm_cert.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_elb_target_group.arn
  }
}
