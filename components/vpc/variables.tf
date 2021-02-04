variable "nginx_igw_name" {
  default = "nginxIGW"
}

variable "nginx_public_subnet_a_cidr_block" {
  default = "10.10.0.0/24"
}

variable "nginx_public_subnet_b_cidr_block" {
  default = "10.10.1.0/24"
}

variable "nginx_private_subnet_a_cidr_block" {
  default = "10.10.2.0/24"
}

variable "nginx_private_subnet_b_cidr_block" {
  default = "10.10.3.0/24"
}

variable "nginx_public_route_table_cidr_block" {
  default = "0.0.0.0/0"
}
