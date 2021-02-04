data "aws_route53_zone" "techops_dev_route53_zone" {
  name = var.route53_zone
}

data "aws_lb" "nginx_load_balancer" {
  name = var.nginx_load_balancer_name
}

resource "aws_route53_record" "nginx_techops_dev_route53_route" {
  name    = var.nginx_route53_record_name
  type    = "CNAME"
  records = [data.aws_lb.nginx_load_balancer.dns_name]
  zone_id = data.aws_route53_zone.techops_dev_route53_zone.id
  ttl     = 300
}
