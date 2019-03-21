variable "account_id" {}
variable "namespace" {}

locals {
  namespace = "${var.namespace}-${terraform.workspace}-logging"
}

# LOGGING

data "template_file" "logging" {
  template = "${file("./modules/aws/s3/logging/tpl/logging.tpl")}"

  vars {
    bucket = "${local.namespace}"
    account = "${var.account_id}"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${local.namespace}"
  acl = "log-delivery-write"

  policy = "${data.template_file.logging.rendered}"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id = "${local.namespace}-lifecycle"
    enabled = true

    transition {
      days = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 395
    }

    tags {
      rule = "glacier"
    }
  }
}


# OUTPUT

output "arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

output "id" {
  value = "${aws_s3_bucket.bucket.id}"
}
