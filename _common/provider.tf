variable "region" {}
variable "profile" {}

provider "aws" {
  # if empty this will provide from ENVIRONEMNT
  region  = "${var.region}"
  profile = "${var.profile}"

  version = "~> 1.54.0"
}

provider "template" {
  version = "~> 1.0"
}
