locals {
  github_organization = ""
  github_token        = ""
}

locals {
  source_config = {
    Owner      = "${local.github_organization}"
    Repo       = "amibfix-runtime"
    Branch     = "master"
    OAuthToken = "${local.github_token}"
  }
}
