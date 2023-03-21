terraform {
  backend "s3" {
    bucket   = "bucket75"
    key      = "infra/terraform.tfstate"
    region   = "eu-west-2"
    dynamodb_table = "my-terraform-state-lock-table"
  }
 }