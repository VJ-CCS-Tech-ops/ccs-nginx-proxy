data "aws_route53_zone" "techops_dev_route53_zone" {
  name = var.route53_zone
}

resource "aws_acm_certificate" "nginx_acm_cert" {
  domain_name       = var.acm_domain_name
  validation_method = "DNS"

  tags = {
    Name = "nginx ACM Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}
#
resource "aws_route53_record" "techops_dev_nginx_record" {
  for_each = {
    for acm_cert in aws_acm_certificate.nginx_acm_cert.domain_validation_options : acm_cert.domain_name => {
      name   = acm_cert.resource_record_name
      record = acm_cert.resource_record_value
      type   = acm_cert.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = "CNAME"
  zone_id = data.aws_route53_zone.techops_dev_route53_zone.id
}

resource "aws_acm_certificate_validation" "nginx_acm_cert_validation" {
  certificate_arn         = aws_acm_certificate.nginx_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.techops_dev_nginx_record : record.fqdn]
}
