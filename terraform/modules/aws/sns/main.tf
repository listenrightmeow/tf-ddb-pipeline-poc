variable "endpoint_arn" {}
variable "protocol" {}
variable "topic_arn" {}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = "${var.topic_arn}"
  protocol  = "${var.protocol}"
  endpoint  = "${var.endpoint_arn}"
}

# OUTPUT

output "arn" {
  value = "${aws_sns_topic_subscription.subscription.arn}"
}

output "topic_arn" {
  value = "${aws_sns_topic_subscription.subscription.topic_arn}"
}
