resource "aws_cloudwatch_log_group" "codebuildlogs" {
  name              = "${terraform.workspace}-codebuild"
  retention_in_days = 120
  tags              = "${local.tags}"
}
