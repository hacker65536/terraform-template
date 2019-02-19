#data "github_repository" "repo" {
#  //full_name = "hacker65536/ci_test"
#  name = "ci_test"
#}
#
#/*
#resource "github_repository" "repo" {
#  name         = "foo"
#  description  = "Terraform acceptance tests"
#  homepage_url = "https://github.com/hacker65536/ci_test"
#
#  private = false
#}
#
#resource "github_repository_webhook" "foo" {
#  repository = "${github_repository.repo.name}"
#
#  name = "web"
#
#  configuration {
#    url          = "https://google.de/"
#    content_type = "form"
#    insecure_ssl = false
#  }
#
#  active = false
#
#  events = ["issues"]
#}
#*/
#output "github" {
#  value = "${data.github_repository.repo.description}"
#}

