output "mysql_addresses" {
  value = [
    "${aws_db_instance.mysql56.*.address}",
    "${aws_db_instance.mysql57.*.address}",
    "${aws_db_instance.mysql80.*.address}",
  ]
}
