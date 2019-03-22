variable "account_id" {}
variable "logging_id" {}
variable "region" {}
variable "security_group_ids" {}
variable "subnets" {}

# DDB
# DDB:TABLE
module "table" {
  source = "./ddb"
}

# IAM
module "iam" {
  source = "./iam"
  account_id = "${var.account_id}"
  region = "${var.region}"
  table_name = "${module.table.name}"
}

# NOTE: this is the "reducer" subscription that other λs
# will recieve Stream events from
module "topic" {
  source = "../../../../modules/aws/sns/topic"
  service = "stream"
}

# NOTE: this is the Dead Letter Queue for λ functions
module "dlq" {
  source = "../../../../modules/aws/sns/topic"
  service = "dlq"
}

# SNS:SUBSCRIPTION
module "subscription" {
  source = "../../../../modules/aws/sns"
  endpoint_arn = "${module.worker.arn}"
  protocol = "lambda"
  topic_arn = "${module.topic.arn}"
}

# λ:WORKER:RER
module "worker" {
  source = "./lambda/worker"
  logging_id = "${var.logging_id}"
  namespace = "poc"
  role_arn = "${module.iam.role_arn}"
  security_group_ids = "${var.security_group_ids}"
  subnets = "${var.subnets}"
}

# λ:REDUCER:RER
module "controller" {
  source = "./lambda/controller"
  dlq_arn = "${module.dlq.arn}"
  logging_id = "${var.logging_id}"
  namespace = "poc"
  role_arn = "${module.iam.role_arn}"
  security_group_ids = "${var.security_group_ids}"
  subnets = "${var.subnets}"
  topic_arn = "${module.subscription.topic_arn}"
}

# DDB:STREAM:λ:RER
resource "aws_lambda_event_source_mapping" "controller" {
  batch_size = 100
  event_source_arn = "${module.table.stream}"
  enabled = true
  function_name = "${module.controller.arn}"
  starting_position = "TRIM_HORIZON"
}

# λ:SNS:PERMISSIONS:RER
resource "aws_lambda_permission" "permissions" {
  action = "lambda:InvokeFunction"
  function_name = "${module.worker.name}"
  principal = "sns.amazonaws.com"
  source_arn = "${module.topic.arn}"
}

# OUTPUT
