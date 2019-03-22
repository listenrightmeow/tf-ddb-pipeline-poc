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

# λ:WORKER
module "worker" {
  source = "./lambda/worker"
  logging_id = "${var.logging_id}"
  namespace = "poc"
  role_arn = "${module.iam.role_arn}"
  security_group_ids = "${var.security_group_ids}"
  subnets = "${var.subnets}"
  topic_arn = "${module.topic.arn}"
}

# λ:TIMESTAMP
module "timestamp" {
  source = "./lambda/timestamp"
  logging_id = "${var.logging_id}"
  namespace = "poc"
  role_arn = "${module.iam.role_arn}"
  security_group_ids = "${var.security_group_ids}"
  subnets = "${var.subnets}"
  topic_arn = "${module.topic.arn}"
}

# λ:REDUCER
module "controller" {
  source = "./lambda/controller"
  dlq_arn = "${module.dlq.arn}"
  logging_id = "${var.logging_id}"
  namespace = "poc"
  role_arn = "${module.iam.role_arn}"
  security_group_ids = "${var.security_group_ids}"
  subnets = "${var.subnets}"
  table_stream = "${module.table.stream}"
  topic_arn = "${module.worker.subscription_arn}"
}

# OUTPUT
