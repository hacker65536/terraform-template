locals {
  source_config = {
    Owner  = "${var.github_organization}"
    Repo   = "amibfix-runtime"
    Branch = "master"

    OAuthToken = "${var.github_token}"
  }
}
