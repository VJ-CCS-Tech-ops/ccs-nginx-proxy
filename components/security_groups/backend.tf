terraform {
  backend "s3" {
    bucket         = "nginx-infrastructure-tfstate"
    key            = "security_groups/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "nginx-infrastructure-tfstate"
  }
}
