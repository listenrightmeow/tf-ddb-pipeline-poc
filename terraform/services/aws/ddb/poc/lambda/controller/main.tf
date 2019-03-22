variable "dlq_arn" {}
variable "logging_id" {}
variable "namespace" {}
variable "role_arn" {}
variable "security_group_ids" {}
variable "subnets" {}
variable "table_stream" {}
variable "topic_arn" {}

variable "path" {
  type = "string"
  default = "./services/aws/ddb/poc/lambda/controller"
}

resource "null_resource" "null" {
  triggers {
    index = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "npm i"
    working_dir = "${var.path}/fn"
  }
}

data "archive_file" "zip" {
  type = "zip"
  source_dir = "${var.path}/fn"
  output_path = "${var.path}/output/function.zip"
  depends_on = ["null_resource.null"]
}

resource "aws_lambda_function" "function" {
  function_name = "${terraform.workspace}-${var.namespace}-controller"
  description = "${terraform.workspace} DDB Stream controller"
  handler = "index.handler"
  runtime = "nodejs8.10"
  filename = "${var.path}/output/function.zip"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  role = "${var.role_arn}"
  memory_size = 128
  timeout = 30

  dead_letter_config {
    target_arn = "${var.dlq_arn}"
  }

  environment {
    variables {
      NODE_ENV = "${terraform.workspace}"
      AWS_TOPIC_ARN = "${var.topic_arn}"
    }
  }

  vpc_config {
    subnet_ids = ["${split(",", var.subnets)}"]
    security_group_ids = ["${split(",", var.security_group_ids)}"]
  }

  tags {
    Name = "pipeline:${var.namespace}:controller"
  }

  depends_on = ["data.archive_file.zip"]
}

# DDB:STREAM:λ:RER
resource "aws_lambda_event_source_mapping" "controller" {
  batch_size = 100
  event_source_arn = "${var.table_stream}"
  enabled = true
  function_name = "${aws_lambda_function.function.arn}"
  starting_position = "TRIM_HORIZON"
}

# OUTPUT

output "arn" {
  value = "${aws_lambda_function.function.arn}"
}
