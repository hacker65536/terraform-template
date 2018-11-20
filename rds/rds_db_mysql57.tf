locals {
  mysql57engines = [
    "5.7.23",
  ]
}

resource "aws_db_instance" "mysql57" {
  count      = "${length(local.mysql57engines)}"
  identifier = "${terraform.workspace}-mysql${replace(element(local.mysql57engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mysql"
  engine_version       = "${element(local.mysql57engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mysql57.id}"

  //parameter_group_name   = "default.mysql5.6"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  skip_final_snapshot    = true
  apply_immediately      = true

  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  backup_retention_period = 1

  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mysql${replace(element(local.mysql57engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mysql57" {
  name   = "${terraform.workspace}-mysql57-parameter-group"
  family = "mysql5.7"
  tags   = "${local.tags}"
}

resource "aws_db_option_group" "mysql57" {
  name                 = "${terraform.workspace}-mysql57-option-group"
  engine_name          = "mysql"
  major_engine_version = "5.7"
}

output "mysql57_endpoints" {
  value = "${aws_db_instance.mysql57.*.endpoint}"
}

output "mysql57_addresses" {
  value = "${aws_db_instance.mysql57.*.address}"
}

output "mysql57_ids" {
  value = "${aws_db_instance.mysql57.*.id}"
}
