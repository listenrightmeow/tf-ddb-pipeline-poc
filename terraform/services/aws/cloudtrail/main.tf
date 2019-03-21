variable "bucket_name" {}
variable "include_global_service_events" {
  type = "string"
  default = "false"
}
variable "prefix" {}

locals {
  include_global_service_events = "${var.include_global_service_events == "false" ? false : true}"
  namespace = "${terraform.workspace}-${var.prefix}"
}

resource "aws_cloudtrail" "region" {
  name = "${local.namespace}"
  include_global_service_events = "${local.include_global_service_events}"
  s3_bucket_name = "${var.bucket_name}"
  s3_key_prefix = "cloudtrail-${local.namespace}"
}
