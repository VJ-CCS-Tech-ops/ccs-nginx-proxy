terraform {
  backend "s3" {
    bucket         = "nginx-infrastructure-tfstate"
    key            = "route53/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "nginx-infrastructure-tfstate"
  }
}
