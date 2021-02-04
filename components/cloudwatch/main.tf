resource "aws_cloudwatch_log_group" "nginx_cloudwatch" {
  name              = var.nginx_cloudwatch_log_group_name
  retention_in_days = 14
}
