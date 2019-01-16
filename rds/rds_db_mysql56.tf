locals {
  mysql56engines = [
    "5.6.41",
  ]
}

resource "aws_db_instance" "mysql56" {
  count      = "${length(local.mysql56engines)}"
  identifier = "${terraform.workspace}-mysql${replace(element(local.mysql56engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mysql"
  engine_version       = "${element(local.mysql56engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mysql56.id}"

  //parameter_group_name   = "default.mysql5.6"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  skip_final_snapshot    = true
  apply_immediately      = true

  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  backup_retention_period = 1
  backup_window           = "16:15-16:45"

  //snapshot_identifier     = "${terraform.workspace}-mysql${replace(element(local.mysql56engines,count.index),".","")}-200-2000000"

  multi_az = false
  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]
  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mysql${replace(element(local.mysql56engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mysql56" {
  name   = "${terraform.workspace}-mysql56-parameter-group"
  family = "mysql5.6"
  tags   = "${local.tags}"

  parameter {
    name  = "max_prepared_stmt_count"
    value = "1048576"
  }

  /*
  parameter {
    name  = "general_log"
    value = "1"
    //value = ""
  }
	*/

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

resource "aws_db_option_group" "mysql56" {
  name                 = "${terraform.workspace}-mysql56-option-group"
  engine_name          = "mysql"
  major_engine_version = "5.6"
}

output "mysql56_endpoints" {
  value = "${aws_db_instance.mysql56.*.endpoint}"
}

output "mysql56_addresses" {
  value = "${aws_db_instance.mysql56.*.address}"
}

output "mysql56_ids" {
  value = "${aws_db_instance.mysql56.*.id}"
}

output "mysql56_az" {
  value = "${aws_db_instance.mysql56.*.availability_zone}"
}
