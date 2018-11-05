data "aws_ecr_repository" "ecr" {
  name = "${data.terraform_remote_state.ecr.ecr_name}"
}
