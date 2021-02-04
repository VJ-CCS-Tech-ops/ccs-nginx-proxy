data "aws_canonical_user_id" "current_user" {}

resource "aws_dynamodb_table" "nginx_infrastructure_terraform_state_dynamodb_table" {
  hash_key       = var.nginx_infrastructure_terraform_state_dynamodb_hash_key
  name           = var.nginx_infrastructure_terraform_state_dynamodb_table_name
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "nginx_infrastructure_logging_s3_bucket" {
  bucket = var.nginx_infrastructure_logging_s3_bucket_name

  grant {
    permissions = ["READ_ACP", "WRITE"]
    type        = "Group"
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["READ_ACP", "WRITE_ACP", "WRITE", "READ"]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "nginx Infrastructure Logging Bucket"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "nginx_infrastructure_terraform_state_s3_bucket" {
  acl    = "private"
  bucket = var.nginx_infrastructure_terraform_state_s3_bucket_name

  tags = {
    Name = var.nginx_infrastructure_terraform_state_s3_bucket_name
  }

  logging {
    target_bucket = var.nginx_infrastructure_logging_s3_bucket_name
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "nginx_infrastructure_logging_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.nginx_infrastructure_logging_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "nginx_infrastructure_terraform_state_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.nginx_infrastructure_terraform_state_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
