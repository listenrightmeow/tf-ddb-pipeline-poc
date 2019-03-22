variable "account_id" {}
variable "region" {}
variable "table_name" {}

resource "aws_iam_role" "role" {
  name = "${terraform.workspace}-${var.table_name}-lambda-role"
  assume_role_policy = "${file("./services/aws/ddb/poc/iam/tpl/role.tpl")}"

  lifecycle {
    ignore_changes = ["force_detach_policies"]
  }
}

data "template_file" "policy" {
  template = "${file("./services/aws/ddb/poc/iam/tpl/policy.tpl")}"

  vars {
    account_id = "${var.account_id}"
    region = "${var.region}"
    table_name = "${var.table_name}"
  }
}

resource "aws_iam_role_policy" "policy" {
 depends_on = ["aws_iam_role.role"]
 name = "${terraform.workspace}-${var.table_name}-lambda-policy"
 role = "${aws_iam_role.role.name}"
 policy = "${data.template_file.policy.rendered}"
}

# OUTPUT

output "role_arn" {
  value = "${aws_iam_role.role.arn}"
}
