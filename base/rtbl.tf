locals {
  # checkip.amazonaws.com
  checkip = [
    "52.202.139.131/32",
    "34.196.82.108/32",
    "52.0.208.170/32",
    "52.200.125.74/32",
    "34.233.102.38/32",
    "18.233.42.138/32",
  ]
}

resource "aws_default_route_table" "def" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  tags                   = "${merge(local.tags, map("Name", "def_rtbl"))}"
}

resource "aws_route_table" "pub" {
  tags   = "${merge(local.tags, map("Name", "pub_rtbl"))}"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "pub" {
  route_table_id         = "${aws_route_table.pub.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  depends_on             = ["aws_route_table.pub"]
}

resource "aws_route_table" "pub_nat" {
  count  = "${var.nat == 0 ? 0 : 1}"
  tags   = "${merge(local.tags, map("Name", "pub_natrtbl"))}"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "pub_nat" {
  count                  = "${var.nat == 0 ? 0 : 1}"
  route_table_id         = "${aws_route_table.pub_nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  depends_on             = ["aws_route_table.pub_nat"]
}

//specific route
resource "aws_route" "pub2nat" {
  count                  = "${var.nat == 0 ? 0 : length(local.checkip)}"
  route_table_id         = "${aws_route_table.pub_nat.id}"
  destination_cidr_block = "${element(local.checkip,count.index)}"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
  depends_on             = ["aws_route_table.pub_nat"]
}

resource "aws_route_table" "pri_nat" {
  count  = "${var.nat == 0 ? 0 : 1}"
  tags   = "${merge(local.tags, map("Name", "pri_natrtbl"))}"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "pri_nat" {
  count                  = "${var.nat == 0 ? 0 : 1}"
  route_table_id         = "${aws_route_table.pri_nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
  depends_on             = ["aws_route_table.pri_nat"]
}
