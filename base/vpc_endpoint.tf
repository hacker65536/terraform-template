resource "aws_vpc_endpoint" "ep" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}
