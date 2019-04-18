variable "region" {}
variable "profile" {}

provider "aws" {
  # if empty this will provide from ENVIRONEMNT
  region  = "${var.region}"
  profile = "${var.profile}"

  version = "~> 2.6.0"
}

provider "template" {
  version = "~> 2.1.1"
}
