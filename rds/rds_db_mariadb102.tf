locals {
  mariadb102engines = [
    "10.2.15",
  ]
}

resource "aws_db_instance" "mariadb102" {
  count      = "${length(local.mariadb102engines)}"
  identifier = "${terraform.workspace}-mariadb${replace(element(local.mariadb102engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mariadb"
  engine_version       = "${element(local.mariadb102engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mariadb102.id}"

  //parameter_group_name   = "default.mysql5.6"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  skip_final_snapshot    = true
  apply_immediately      = true

  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  backup_retention_period = 1

  enabled_cloudwatch_logs_exports = [
    "slowquery",
  ]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mariadb${replace(element(local.mariadb102engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mariadb102" {
  name   = "${terraform.workspace}-mariadb102-parameter-group"
  family = "mariadb10.2"
  tags   = "${local.tags}"
}

output "mariadb102_endpoints" {
  value = "${aws_db_instance.mariadb102.*.endpoint}"
}

output "mariadb102_addresses" {
  value = "${aws_db_instance.mariadb102.*.address}"
}

output "mariadb102_ids" {
  value = "${aws_db_instance.mariadb102.*.id}"
}
