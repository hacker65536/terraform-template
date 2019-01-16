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
  backup_window           = "16:15-16:45"

  //snapshot_identifier     = "${terraform.workspace}-mysql${replace(element(local.mysql57engines,count.index),".","")}-200-2000000"

  multi_az = false
  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]
  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mysql${replace(element(local.mysql57engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mysql57" {
  name   = "${terraform.workspace}-mysql57-parameter-group"
  family = "mysql5.7"
  tags   = "${local.tags}"

  parameter {
    name  = "max_prepared_stmt_count"
    value = "1048576"
  }

  /*
  parameter {
    name = "innodb_log_file_size"

    //value = "1073741824"

    //default
    value        = "134217728"
    apply_method = "pending-reboot"
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

output "mysql57_az" {
  value = "${aws_db_instance.mysql57.*.availability_zone}"
}
