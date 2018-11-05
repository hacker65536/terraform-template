data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket  = "${terraform.workspace}-state"
    key     = "base/${terraform.workspace}/terraform_state"
    region  = "${data.aws_region.region.name}"
    profile = "${var.profile}"
  }
}
