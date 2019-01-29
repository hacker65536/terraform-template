locals {
  mariadb101engines = [
    "10.1.34",
  ]
}

resource "aws_db_instance" "mariadb101" {
  count      = "${length(local.mariadb101engines)}"
  identifier = "${terraform.workspace}-mariadb${replace(element(local.mariadb101engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mariadb"
  engine_version       = "${element(local.mariadb101engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mariadb101.id}"

  //parameter_group_name   = "default.mysql5.6"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  skip_final_snapshot    = true
  apply_immediately      = true

  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  backup_retention_period = 1
  backup_window           = "16:15-16:45"

  //snapshot_identifier = "${terraform.workspace}-mariadb${replace(element(local.mariadb101engines,count.index),".","")}-200-2000000"

  multi_az = false
  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]
  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-mariadb${replace(element(local.mariadb101engines,count.index),".","")}"))}"
}

resource "aws_db_parameter_group" "mariadb101" {
  name   = "${terraform.workspace}-mariadb101-parameter-group"
  family = "mariadb10.1"
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

resource "aws_db_option_group" "mariadb101" {
  name                 = "${terraform.workspace}-mariadb101-option-group"
  engine_name          = "mariadb"
  major_engine_version = "10.1"
}

output "mariadb101_endpoints" {
  value = "${aws_db_instance.mariadb101.*.endpoint}"
}

output "mariadb101_addresses" {
  value = "${aws_db_instance.mariadb101.*.address}"
}

output "mariadb101_ids" {
  value = "${aws_db_instance.mariadb101.*.id}"
}
