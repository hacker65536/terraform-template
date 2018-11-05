locals {
  subnetprefix = [
    "pub",
    "pri",
    "nat",
  ]

  # if want to distribute 3 zones like  us-west-2a,us-west-2b,us-west-2c
  multi_azs = 3
}

resource "aws_subnet" "pub" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = true

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pub","SubnetRole","pub"))}"
}

resource "aws_subnet" "pri" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pri","SubnetRole","pri"))}"
}

resource "aws_subnet" "pub_nat" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs * 2)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pub-nat","SubnetRole","pub_nat"))}"
}

resource "aws_subnet" "pri_nat" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs * 3)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pri-nat","SubnetRole","pri_nat"))}"
}
