provider "aws" {
  version = "~> 2.2.0"
  region = "us-west-2"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_caller_identity" "account" {}

# REGIONAL

module "logging" {
  source = "./modules/aws/s3/logging"
  account_id = "${data.aws_caller_identity.account.account_id}"
  namespace = "${var.namespace}"
}

module "cloudtrail" {
  source = "./services/aws/cloudtrail"
  bucket_name = "${module.logging.id}"
  include_global_service_events = "true"
  prefix = "basic"
}

# OUTPUT

output "account_id" {
  value = "${data.aws_caller_identity.account.account_id}"
}
