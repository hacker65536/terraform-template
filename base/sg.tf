resource "aws_security_group" "sg1" {
  name        = "${terraform.workspace}-sec"
  description = "sec"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-sec"),map("sg","sec"))}"
}

resource "aws_security_group_rule" "sg11" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"
  self      = true

  security_group_id = "${aws_security_group.sg1.id}"
}

resource "aws_security_group_rule" "sg12" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = "${var.secips}"

  security_group_id = "${aws_security_group.sg1.id}"
}
