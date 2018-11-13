locals {
  aurora56engines = [
    "5.6.10a",
  ]
}

resource "aws_rds_cluster" "aurora56" {
  cluster_identifier     = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}"
  engine                 = "aurora"
  database_name          = "${local.db_name}"
  master_username        = "${local.rds_sec["username"]}"
  master_password        = "${local.rds_sec["password"]}"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora56.id}"
  skip_final_snapshot             = true

  enabled_cloudwatch_logs_exports = [
    "slowquery",
  ]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}"))}"
}

resource "aws_rds_cluster_instance" "aurora56" {
  #  identifier           = "${terraform.workspace}-aurora-${count.index}"
  count                   = "${length(local.aurora56engines)}"
  identifier_prefix       = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}-"
  cluster_identifier      = "${aws_rds_cluster.aurora56.id}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  db_parameter_group_name = "${aws_db_parameter_group.aurora56.id}"
  instance_class          = "${local.db_class}"
  engine                  = "aurora"
  engine_version          = "${element(local.aurora56engines,count.index)}"

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "aurora56" {
  name   = "${terraform.workspace}-aurora56-db-parameter-group"
  family = "aurora5.6"
  tags   = "${local.tags}"
}

resource "aws_rds_cluster_parameter_group" "aurora56" {
  name   = "${terraform.workspace}-aurora56-cluster-parameter-group"
  family = "aurora5.6"
  tags   = "${local.tags}"
}

output "aurora56_endpoints" {
  value = "${aws_rds_cluster.aurora56.*.endpoint}"
}

output "aurora56_addresses" {
  value = "${aws_rds_cluster.aurora56.*.endpoint}"
}

output "aurora56_ids" {
  value = "${aws_rds_cluster.aurora56.*.id}"
}

/*
output "aurora56_storage" {
  value = "${aws_rds_cluster.aurora56.*.allocated_storage}"
}
*/

