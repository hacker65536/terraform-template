data "github_repository" "repo" {
  //name      = "${lookup(local.source_config,"Repo")}"  //full_name = "techadmin/${lookup(local.source_config,"Repo")}"  //full_name = "hacker65536/ci_test"  //name = "ci_test"
}

locals {
  webhook_secret = "ga-secret2"
}

# automatically set to github
resource "aws_codebuild_webhook" "codebuild" {
  project_name  = "${aws_codebuild_project.codebuild.name}"
  branch_filter = "master"
}

resource "github_repository_webhook" "codebuild" {
  active = true
  events = ["push", "pull_request"]

  // only "web"
  name       = "web"
  repository = "${data.github_repository.repo.name}"

  configuration {
    url          = "${aws_codebuild_webhook.codebuild.payload_url}"
    secret       = "${aws_codebuild_webhook.codebuild.secret}"
    content_type = "json"
    insecure_ssl = true
  }
}

output "output" {
  value = "${aws_codebuild_webhook.codebuild.payload_url}"
}

output "output2" {
  value = "${aws_codebuild_webhook.codebuild.secret}"
}
