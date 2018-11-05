resource "aws_alb" "alb" {
  name = "${terraform.workspace}-alb"

  security_groups = [
    "${data.aws_security_group.sec.id}",
  ]

  subnets = ["${data.aws_subnet_ids.pub.ids}"]

  /*
  access_logs {
    bucket = "${aws_s3_bucket.alb_log.bucket}"
    prefix = "alb-app"
  }
	*/

  tags = "${local.tags}"
}
