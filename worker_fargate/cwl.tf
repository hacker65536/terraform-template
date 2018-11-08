locals {
  loggroups = [
    "nginx",
    "fpm",
  ]
}

resource "aws_cloudwatch_log_group" "clg" {
  count = "${length(local.loggroups)}"
  name  = "${terraform.workspace}-${element(local.loggroups,count.index)}"
  tags  = "${local.tags}"
}
