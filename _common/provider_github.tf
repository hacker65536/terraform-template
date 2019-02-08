variable "github_token" {}
variable "github_organization" {}

provider "github" {
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
  version      = "~> 1.3.0"
}
