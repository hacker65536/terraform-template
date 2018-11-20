resource "aws_cloudwatch_log_group" "ssm" {
  name              = "${terraform.workspace}-ssm-sendcommand"
  retention_in_days = 120
}
