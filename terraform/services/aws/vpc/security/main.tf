variable "vpc_id" {}

resource "aws_security_group" "internet" {
  name = "${terraform.workspace}-internet"
  description = "Allow internet egress from subnet"

  vpc_id = "${var.vpc_id}"

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
  }

  lifecycle {
    create_before_destroy = true
  }
}

# OUTPUT

output "internet" {
  value = "${aws_security_group.internet.id}"
}
