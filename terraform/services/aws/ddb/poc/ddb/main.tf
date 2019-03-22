data "aws_iam_role" "DynamoDBAutoscaleRole" {
  name = "AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
}

module "table" {
  source = "./table"
  name = "StreamPOC"
  hash_key = "partitionId"
  hash_key_type = "S"
  role_arn = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
}

module "documents_table_autoscale" {
  source = "./autoscale"
  table_name = "${module.table.table_name}"
  role_arn = "${data.aws_iam_role.DynamoDBAutoscaleRole.arn}"
}

# OUTPUT

output "name" {
  value = "${module.table.table_name}"
}

output "stream" {
  value = "${module.table.stream_arn}"
}
