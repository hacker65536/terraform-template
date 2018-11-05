locals {
  vpc_endpoints_gateway = [
    "${data.aws_vpc_endpoint_service.s3.service_name}",
  ]

  vpc_endpoints_interface = [
    "${data.aws_vpc_endpoint_service.secretsmanager.service_name}",
  ]
}

resource "aws_vpc_endpoint" "ep_gateway" {
  count             = "${length(local.vpc_endpoints_gateway)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  service_name      = "${element(local.vpc_endpoints_gateway,count.index)}"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "ep_interface" {
  count               = "${length(local.vpc_endpoints_interface)}"
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "${element(local.vpc_endpoints_interface,count.index)}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["${aws_subnet.pri.*.id}"]
  security_group_ids  = ["${aws_security_group.sec.id}"]
  private_dns_enabled = true
}
