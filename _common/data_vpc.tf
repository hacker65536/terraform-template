data "aws_vpc" "vpc" {
  id = "${data.terraform_remote_state.base.vpc_id}"
}
