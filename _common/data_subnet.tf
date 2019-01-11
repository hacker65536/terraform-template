# subnet_ids = ["${data.aws_subnet_ids.pri.ids}"]

data "aws_subnet_ids" "pub" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    SubnetRole = "pub"
  }
}

data "aws_subnet_ids" "pri" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    SubnetRole = "pri"
  }
}

data "aws_subnet_ids" "pri_nat" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    SubnetRole = "pri_nat"
  }
}

data "aws_subnet" "pub" {
  count = "${length(data.aws_subnet_ids.pub.ids)}"
  id    = "${data.aws_subnet_ids.pub.ids[count.index]}"
}

data "aws_subnet" "pri" {
  count = "${length(data.aws_subnet_ids.pri.ids)}"
  id    = "${data.aws_subnet_ids.pri.ids[count.index]}"
}

data "aws_subnet" "pri_nat" {
  count = "${length(data.aws_subnet_ids.pri_nat.ids)}"
  id    = "${data.aws_subnet_ids.pri_nat.ids[count.index]}"
}

output "subnet_ids_pub" {
  value = "${data.aws_subnet_ids.pub.ids}"
}
