output "mysql_addresses" {
  value = [
    "${aws_db_instance.mysql56.*.address}",
    "${aws_db_instance.mysql57.*.address}",
    "${aws_db_instance.mysql80.*.address}",
    "${aws_db_instance.mariadb102.*.address}",
    "${aws_db_instance.mariadb103.*.address}",
    "${aws_rds_cluster.aurora56.*.endpoint}",
    "${aws_rds_cluster.aurora57.*.endpoint}",
  ]
}
