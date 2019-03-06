#variable "github_token" {}
#variable "github_organization" {}

provider "github" {
  token        = "${local.github_token}"
  organization = "${local.github_organization}"
  version      = "~> 1.3.0"
}
