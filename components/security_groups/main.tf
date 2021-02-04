data "aws_vpc" "nginx_vpc" {
  tags = {
    Name = var.nginx_vpc_name
  }
}

resource "aws_security_group" "nginx_security_group" {
  name        = var.nginx_security_group_name
  description = "Security group for nginx"
  vpc_id      = data.aws_vpc.nginx_vpc.id
}

resource "aws_security_group" "nginx_elb_security_group" {
  name        = var.nginx_load_balancer_security_group_name
  description = "Security group for load balancer"
  vpc_id      = data.aws_vpc.nginx_vpc.id

  ingress {
    # Trusted IPs
    cidr_blocks = ["51.149.9.112/29", "51.149.9.240/29"]
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
  }

  egress {
    from_port       = 8080
    protocol        = "TCP"
    to_port         = 8080
    security_groups = [aws_security_group.nginx_security_group.id]
  }
}

resource "aws_security_group" "nginx_efs_security_group" {
  name        = var.nginx_efs_security_group_name
  description = "Enable EFS access via port 2049"
  vpc_id      = data.aws_vpc.nginx_vpc.id

  ingress {
    from_port       = 2049
    protocol        = "TCP"
    to_port         = 2049
    security_groups = [aws_security_group.nginx_security_group.id]
  }
}

resource "aws_security_group_rule" "nginx_sg_ingress_to_nginx_lb_sg" {
  from_port                = 8080
  protocol                 = "TCP"
  security_group_id        = aws_security_group.nginx_security_group.id
  source_security_group_id = aws_security_group.nginx_elb_security_group.id
  to_port                  = 8080
  type                     = "ingress"
}

resource "aws_security_group_rule" "nginx_sg_outbound_access" {
  from_port         = 0
  protocol          = "TCP"
  security_group_id = aws_security_group.nginx_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 65535
  type              = "egress"
}
