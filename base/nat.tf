resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.pub_nat.*.id[0]}"
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-nat-ip"))}"
}
