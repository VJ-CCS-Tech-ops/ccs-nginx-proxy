variable "nginx_vpc_name" {
  default = "nginxVPC"
}

variable "nginx_public_subnet_a_name" {
  default = "nginxPublicSubnetA"
}

variable "nginx_public_subnet_b_name" {
  default = "nginxPublicSubnetB"
}

variable "nginx_private_subnet_a_name" {
  default = "nginxPrivateSubnetA"
}

variable "nginx_private_subnet_b_name" {
  default = "nginxPrivateSubnetB"
}

variable "nginx_security_group_name" {
  default = "nginxSecurityGroup"
}

variable "nginx_load_balancer_security_group_name" {
  default = "nginxLoadBalancerSecurityGroup"
}

variable "nginx_efs_security_group_name" {
  default = "nginxEFSSecurityGroup"
}

variable "nginx_cloudwatch_log_group_name" {
  default = "nginxCloudWatchLogGroup"
}

variable "nginx_efs_name" {
  default = "nginx-home"
}

variable "nginx_role" {
  default = "nginxRole"
}

variable "nginx_execution_role" {
  default = "nginxExecutionRole"
}

variable "nginx_target_group_name" {
  default = "nginxTargetGroup"
}

variable "nginx_load_balancer_name" {
  default = "nginxLoadBalancer"
}

variable "acm_domain_name" {
  default = "*.techopsdev.com"
}

variable "private_subnet_az_a" {
  default = "eu-west-2a"
}

variable "private_subnet_az_b" {
  default = "eu-west-2b"
}

variable "public_subnet_az_a" {
  default = "eu-west-2a"
}

variable "public_subnet_az_b" {
  default = "eu-west-2b"
}

variable "region" {
  default = "eu-west-2"
}
