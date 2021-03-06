data "aws_security_group" "https" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  filter {
    name   = "tag-key"
    values = ["sg"]
  }

  filter {
    name   = "tag-value"
    values = ["https"]
  }
}
