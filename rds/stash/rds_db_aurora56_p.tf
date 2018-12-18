resource "aws_rds_cluster" "aurora56p" {
  cluster_identifier     = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}p"
  engine                 = "aurora"
  engine_mode            = "parallelquery"
  database_name          = "${local.db_name}"
  master_username        = "${local.rds_sec["username"]}"
  master_password        = "${local.rds_sec["password"]}"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora56.id}"
  skip_final_snapshot             = true
  apply_immediately               = true

  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}p"))}"
}

resource "aws_rds_cluster_instance" "aurora56p" {
  #  identifier           = "${terraform.workspace}-aurora-${count.index}"
  count                   = "${length(local.aurora56engines)}"
  identifier_prefix       = "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}p-"
  cluster_identifier      = "${aws_rds_cluster.aurora56p.id}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  db_parameter_group_name = "${aws_db_parameter_group.aurora56p.id}"
  instance_class          = "${local.db_class}"
  engine                  = "aurora"
  engine_version          = "${element(local.aurora56engines,count.index)}"
  apply_immediately       = true

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-aurora${replace(element(local.aurora56engines,count.index),".","")}p"))}"
}

resource "aws_db_parameter_group" "aurora56p" {
  name   = "${terraform.workspace}-aurora56p-db-parameter-group"
  family = "aurora5.6"
  tags   = "${local.tags}"

  parameter {
    name  = "max_prepared_stmt_count"
    value = "1048576"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora56p" {
  name   = "${terraform.workspace}-aurora56p-cluster-parameter-group"
  family = "aurora5.6"
  tags   = "${local.tags}"
}

output "aurora56p_endpoints" {
  value = "${aws_rds_cluster.aurora56p.*.endpoint}"
}

output "aurora56p_addresses" {
  value = "${aws_rds_cluster.aurora56p.*.endpoint}"
}

output "aurora56p_ids" {
  value = "${aws_rds_cluster.aurora56p.*.id}"
}

/*
output "aurora56_storage" {
  value = "${aws_rds_cluster.aurora56.*.allocated_storage}"
}
*/

