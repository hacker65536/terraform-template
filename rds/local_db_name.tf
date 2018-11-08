locals {
  db_name = "${var.db_name == "" ? "sbtest" : var.db_name }"
}
