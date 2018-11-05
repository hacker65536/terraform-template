resource "aws_route_table_association" "pub" {
  count          = "${local.multi_azs}"
  subnet_id      = "${aws_subnet.pub.*.id[count.index]}"
  route_table_id = "${aws_route_table.pub.id}"
}

resource "aws_route_table_association" "pub_nat" {
  count          = "${local.multi_azs}"
  subnet_id      = "${aws_subnet.pub_nat.*.id[count.index]}"
  route_table_id = "${aws_route_table.pub_nat.id}"
}

resource "aws_route_table_association" "pri_nat" {
  count          = "${local.multi_azs}"
  subnet_id      = "${aws_subnet.pri_nat.*.id[count.index]}"
  route_table_id = "${aws_route_table.pri_nat.id}"
}
