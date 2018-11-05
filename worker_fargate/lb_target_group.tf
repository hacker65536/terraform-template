resource "aws_lb_target_group" "target" {
  name        = "${terraform.workspace}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = "${data.aws_vpc.vpc.id}"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
    matcher             = 200
  }

  tags       = "${local.tags}"
  depends_on = ["aws_lb.lb"]
}
