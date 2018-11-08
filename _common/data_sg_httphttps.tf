data "aws_security_groups" "httphttps" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.vpc.id}"]
  }

  filter {
    name   = "tag-key"
    values = ["sg"]
  }

  filter {
    name = "tag-value"

    values = [
      "http",
      "https",
    ]
  }
}
