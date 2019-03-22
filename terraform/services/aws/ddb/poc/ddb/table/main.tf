variable "hash_key" {}
variable "hash_key_type" {}
variable "name" {}
variable "role_arn" {}

resource "aws_dynamodb_table" "table" {
  name = "${terraform.workspace}.${var.name}"
  read_capacity = 5
  write_capacity = 5
  hash_key = "${var.hash_key}"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "${var.hash_key}"
    type = "${var.hash_key_type}"
  }

  server_side_encryption {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      "read_capacity",
      "write_capacity"
    ]
  }

  tags = {
    env = "${terraform.workspace}"
  }
}

# OUTPUT

output "table_name" {
  value = "${aws_dynamodb_table.table.name}"
}

output "stream_arn" {
  value = "${aws_dynamodb_table.table.stream_arn}"
}
