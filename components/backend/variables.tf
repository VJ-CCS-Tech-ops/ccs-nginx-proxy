variable "nginx_infrastructure_terraform_state_dynamodb_table_name" {
  default = "nginx-infrastructure-tfstate"
}

variable "nginx_infrastructure_terraform_state_dynamodb_hash_key" {
  default = "LockID"
}

variable "nginx_infrastructure_logging_s3_bucket_name" {
  default = "nginx-infrastructure-logging-s3-bucket"
}

variable "nginx_infrastructure_terraform_state_s3_bucket_name" {
  default = "nginx-infrastructure-tfstate"
}

variable "region" {
  default = "eu-west-2"
}
