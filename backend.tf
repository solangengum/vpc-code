terraform {
  backend "s3" {
    bucket         = "terrafor-tests"
    dynamodb_table = "Terraform-backend"
    key            = "Terraform-backend-partKey"
    region         = "us-east-2"
  }
}

