locals {
  aurora57engines = [
    "5.7.12",
  ]
}

resource "aws_rds_cluster" "aurora57" {
  cluster_identifier     = "${terraform.workspace}-aurora${replace(element(local.aurora57engines,count.index),".","")}"
  engine                 = "aurora-mysql"
  engine_mode            = "provisioned"
  database_name          = "${local.db_name}"
  master_username        = "${local.rds_sec["username"]}"
  master_password        = "${local.rds_sec["password"]}"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora57.id}"
  skip_final_snapshot             = true
  apply_immediately               = true

  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora57engines,count.index),".","")}"))}"
}

resource "aws_rds_cluster_instance" "aurora57" {
  #  identifier           = "${terraform.workspace}-aurora-${count.index}"
  count                   = "${length(local.aurora57engines)}"
  identifier_prefix       = "${terraform.workspace}-aurora${replace(element(local.aurora57engines,count.index),".","")}-"
  cluster_identifier      = "${aws_rds_cluster.aurora57.id}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  db_parameter_group_name = "${aws_db_parameter_group.aurora57.id}"
  instance_class          = "${local.db_class}"
  engine                  = "aurora-mysql"
  engine_version          = "${element(local.aurora57engines,count.index)}"
  apply_immediately       = true

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora57engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "aurora57" {
  name   = "${terraform.workspace}-aurora57-db-parameter-group"
  family = "aurora-mysql5.7"
  tags   = "${local.tags}"
}

resource "aws_rds_cluster_parameter_group" "aurora57" {
  name   = "${terraform.workspace}-aurora57-cluster-parameter-group"
  family = "aurora-mysql5.7"
  tags   = "${local.tags}"
}

output "aurora57_endpoints" {
  value = "${aws_rds_cluster.aurora57.*.endpoint}"
}

output "aurora57_addresses" {
  value = "${aws_rds_cluster.aurora57.*.endpoint}"
}

output "aurora57_ids" {
  value = "${aws_rds_cluster.aurora57.*.id}"
}

/*
output "aurora57_storage" {
  value = "${aws_rds_cluster.aurora57.*.allocated_storage}"
}
*/

