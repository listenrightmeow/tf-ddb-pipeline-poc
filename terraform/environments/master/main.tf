provider "aws" {
  version = "~> 2.2.0"
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_caller_identity" "account" {}

module "vpc" {
  source = "./services/aws/vpc"
  availability_zones = "${var.availability_zones}"
}

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

module "dynamodb" {
  source = "./services/aws/ddb/poc"
  account_id = "${data.aws_caller_identity.account.account_id}"
  logging_id = "${module.logging.id}"
  region = "${var.region}"
  security_group_ids = "${join(",", list(module.vpc.security_group_internet))}"
  subnets = "${join(",", module.vpc.private_subnets)}"
}

# OUTPUT

output "account_id" {
  value = "${data.aws_caller_identity.account.account_id}"
}
