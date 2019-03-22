variable "logging_id" {}
variable "namespace" {}
variable "role_arn" {}
variable "security_group_ids" {}
variable "subnets" {}

variable "path" {
  type = "string"
  default = "./services/aws/ddb/poc/lambda/worker"
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
  function_name = "${terraform.workspace}-${var.namespace}-worker"
  description = "${terraform.workspace} DDB Stream worker"
  handler = "index.handler"
  runtime = "nodejs8.10"
  filename = "${var.path}/output/function.zip"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  role = "${var.role_arn}"
  memory_size = 128
  timeout = 30

  environment {
    variables {
      NODE_ENV = "${terraform.workspace}"
    }
  }

  vpc_config {
    subnet_ids = ["${split(",", var.subnets)}"]
    security_group_ids = ["${split(",", var.security_group_ids)}"]
  }

  tags {
    Name = "pipeline:${var.namespace}:worker"
  }

  depends_on = ["data.archive_file.zip"]
}

# OUTPUT

output "arn" {
  value = "${aws_lambda_function.function.arn}"
}

output "name" {
  value = "${aws_lambda_function.function.function_name}"
}
