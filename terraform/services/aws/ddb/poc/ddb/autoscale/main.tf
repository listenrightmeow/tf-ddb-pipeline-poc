variable "table_name" {}
variable "role_arn" {}

locals {
  max_read_capacity = 500
  min_read_capacity = 100
  max_write_capacity = 500
  min_write_capacity = 100
}

resource "aws_appautoscaling_target" "read_target" {
  max_capacity = "${local.max_write_capacity}"
  min_capacity = "${local.min_write_capacity}"
  resource_id = "table/${var.table_name}"
  role_arn = "${var.role_arn}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace = "dynamodb"
}

resource "aws_appautoscaling_policy" "poc_table_read_policy" {
  name = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.read_target.resource_id}"
  policy_type = "TargetTrackingScaling"
  resource_id = "${aws_appautoscaling_target.read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.read_target.scalable_dimension}"
  service_namespace = "${aws_appautoscaling_target.read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "write_target" {
  max_capacity = "${local.max_read_capacity}"
  min_capacity = "${local.min_read_capacity}"
  resource_id = "table/${var.table_name}"
  role_arn = "${var.role_arn}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace = "dynamodb"
}

resource "aws_appautoscaling_policy" "poc_table_write_policy" {
  name = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.write_target.resource_id}"
  policy_type = "TargetTrackingScaling"
  resource_id = "${aws_appautoscaling_target.write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.write_target.scalable_dimension}"
  service_namespace = "${aws_appautoscaling_target.write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}

# ALARMS

resource "aws_cloudwatch_metric_alarm" "capacity_utilization_read" {
  alarm_name = "${terraform.workspace}-ddb-capacity-read-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "ConsumedReadCapacityUnits"
  namespace = "AWS/DynamoDB"
  period = "60"
  statistic = "Maximum"
  threshold = "${local.max_read_capacity}"

  dimensions {
    TableName = "${var.table_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "capacity_utilization_write" {
  alarm_name = "${terraform.workspace}-ddb-capacity-write-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "ConsumedWriteCapacityUnits"
  namespace = "AWS/DynamoDB"
  period = "60"
  statistic = "Maximum"
  threshold = "${local.max_write_capacity}"

  dimensions {
    TableName = "${var.table_name}"
  }
}
