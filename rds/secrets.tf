resource "aws_secretsmanager_secret" "sec" {
  name_prefix = "${terraform.workspace}-rds-sec"
  description = "rds-sec"
  tags        = "${local.tags}"
}

resource "aws_secretsmanager_secret_version" "sec" {
  secret_id     = "${aws_secretsmanager_secret.sec.id}"
  secret_string = "${jsonencode(local.rds_sec)}"
}
