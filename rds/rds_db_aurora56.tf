locals {
  aurora56engines = [
    "5.6.10a",
  ]
}

resource "aws_rds_cluster" "aurora56" {
  cluster_identifier     = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}"
  engine                 = "aurora"
  engine_mode            = "provisioned"
  database_name          = "${local.db_name}"
  master_username        = "${local.rds_sec["username"]}"
  master_password        = "${local.rds_sec["password"]}"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

  //snapshot_identifier    = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}-200-2000000"

  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora56.id}"
  skip_final_snapshot             = true
  apply_immediately               = true
  preferred_backup_window         = "16:15-16:45"
  backup_retention_period         = 1
  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
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
  apply_immediately       = true

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "aurora56" {
  name   = "${terraform.workspace}-aurora56-db-parameter-group"
  family = "aurora5.6"
  tags   = "${local.tags}"

  parameter {
    name  = "max_prepared_stmt_count"
    value = "1048576"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"

    //value = ""
  }

  parameter {
    name  = "long_query_time"
    value = "0.5"

    // value = ""
  }

  parameter {
    name  = "log_output"
    value = "FILE"

    //  value = "TABLE"
  }
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

