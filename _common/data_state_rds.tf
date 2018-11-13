data "terraform_remote_state" "rds" {
  backend = "s3"

  config {
    bucket  = "${terraform.workspace}-state"
    key     = "rds/${terraform.workspace}/terraform_state"
    region  = "${data.aws_region.region.name}"
    profile = "${var.profile}"
  }
}
