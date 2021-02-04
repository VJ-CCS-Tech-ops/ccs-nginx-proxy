data "aws_security_group" "nginx_security_group" {
  name = var.nginx_security_group_name
}

data "aws_security_group" "nginx_efs_security_group" {
  name = var.nginx_efs_security_group_name
}

data "aws_subnet" "nginx_private_subnet_a" {
  tags = {
    Name = var.nginx_private_subnet_a_name
  }
}

data "aws_subnet" "nginx_private_subnet_b" {
  tags = {
    Name = var.nginx_public_subnet_b_name
  }
}

data "aws_vpc" "nginx_vpc" {
  tags = {
    Name = var.nginx_vpc_name
  }
}

resource "aws_efs_file_system" "nginx_efs_file_system" {
  encrypted = true

  tags = {
    Name = var.nginx_efs_name
  }
}

resource "aws_efs_access_point" "nginx_efs_access_point" {
  file_system_id = aws_efs_file_system.nginx_efs_file_system.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }

    path = "/nginx-home"
  }
}

resource "aws_efs_mount_target" "efs_mount_private_subnet_a" {
  file_system_id  = aws_efs_file_system.nginx_efs_file_system.id
  security_groups = [data.aws_security_group.nginx_efs_security_group.id]
  subnet_id       = data.aws_subnet.nginx_private_subnet_a.id
}

resource "aws_efs_mount_target" "efs_mount_private_subnet_b" {
  file_system_id  = aws_efs_file_system.nginx_efs_file_system.id
  security_groups = [data.aws_security_group.nginx_efs_security_group.id]
  subnet_id       = data.aws_subnet.nginx_private_subnet_b.id
}
