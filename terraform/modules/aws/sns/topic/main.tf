variable "service" {}

resource "aws_sns_topic" "topic" {
  display_name = "${terraform.workspace}-${var.service}"
  name = "${terraform.workspace}-${var.service}"
}

# OUTPUT

output "arn" {
  value = "${aws_sns_topic.topic.arn}"
}

output "id" {
  value = "${aws_sns_topic.topic.id}"
}
