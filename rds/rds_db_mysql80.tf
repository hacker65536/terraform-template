locals {
  mysql80engines = [
    "8.0.11",
  ]
}

resource "aws_db_instance" "mysql80" {
  count      = "${length(local.mysql80engines)}"
  identifier = "${terraform.workspace}-mysql${replace(element(local.mysql80engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mysql"
  engine_version       = "${element(local.mysql80engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mysql80.id}"

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

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mysql${replace(element(local.mysql80engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mysql80" {
  name   = "${terraform.workspace}-mysql80-parameter-group"
  family = "mysql8.0"
  tags   = "${local.tags}"
}

resource "aws_db_option_group" "mysql80" {
  name                 = "${terraform.workspace}-mysql80-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

output "mysql80_endpoints" {
  value = "${aws_db_instance.mysql80.*.endpoint}"
}

output "mysql80_addresses" {
  value = "${aws_db_instance.mysql80.*.address}"
}

output "mysql80_ids" {
  value = "${aws_db_instance.mysql80.*.id}"
}
