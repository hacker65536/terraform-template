resource "aws_lb" "lb" {
  name = "${terraform.workspace}-alb"

  load_balancer_type = "application"

  security_groups = [
    "${data.aws_security_groups.httphttps.ids}",
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
