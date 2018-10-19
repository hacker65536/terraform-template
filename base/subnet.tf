locals {
  subnetprefix = [
    "pub",
    "pri",
  ]

  # if want to distribute 3 zones like  us-west-2a,us-west-2b,us-west-2c
  multi_azs = 3
}

resource "aws_subnet" "main" {
  count             = "${local.multi_azs * length(local.subnetprefix)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index)}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"

  tags = "${merge(local.tags, map("Name", element(local.subnetprefix,count.index / local.multi_azs)),map("SubnetRole",element(local.subnetprefix,count.index / local.multi_azs)))}"
}
