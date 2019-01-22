# automatically set to github
resource "aws_codebuild_webhook" "codebuild" {
  project_name = "${aws_codebuild_project.codebuild.name}"
}

output "codebuild_webhook" {
  value = [
    "${aws_codebuild_webhook.codebuild.secret}",
    "${aws_codebuild_webhook.codebuild.payload_url}",
    "${aws_codebuild_webhook.codebuild.url}",
  ]
}
