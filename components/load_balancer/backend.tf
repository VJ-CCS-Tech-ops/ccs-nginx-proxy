terraform {
  backend "s3" {
    bucket         = "nginx-infrastructure-tfstate"
    key            = "load_balancer/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "nginx-infrastructure-tfstate"
  }
}
